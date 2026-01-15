import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme/app_colors.dart';

enum DetectionState { idle, validInput, loading, result, error }

class FraudDetectionResult {
  final String status;
  final double confidence;
  final String explanation;

  FraudDetectionResult({
    required this.status,
    required this.confidence,
    required this.explanation,
  });

  factory FraudDetectionResult.fromJson(Map<String, dynamic> json) {
    return FraudDetectionResult(
      status: json['status'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      explanation: json['explanation'] ?? '',
    );
  }
}

class URLDetectionResult {
  final String url;
  final String verdict;
  final String riskScore;
  final List<String> reasons;

  URLDetectionResult({
    required this.url,
    required this.verdict,
    required this.riskScore,
    required this.reasons,
  });

  factory URLDetectionResult.fromJson(Map<String, dynamic> json) {
    return URLDetectionResult(
      url: json['url'] ?? '',
      verdict: json['verdict'] ?? 'Unknown',
      riskScore: json['risk_score'] ?? '0%',
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }
}

enum InputType { text, url, invalid }

enum InputSource { text, imageOcr }

class DetectFraudScreen extends StatefulWidget {
  const DetectFraudScreen({super.key});

  @override
  State<DetectFraudScreen> createState() => _DetectFraudScreenState();
}

class _DetectFraudScreenState extends State<DetectFraudScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  DetectionState _currentState = DetectionState.idle;
  File? _selectedImage;
  String? _extractedText;
  FraudDetectionResult? _detectionResult;
  URLDetectionResult? _urlDetectionResult;
  String? _errorMessage;
  bool _isImageMode = false;

  // Animated placeholder variables
  final List<String> _placeholderTexts = [
    '"Enter Email/SMS"',
    '"Paste URL"',
    '"Paste SMS content"',
    '"Upload image"',
  ];
  int _currentPlaceholderIndex = 0;
  Timer? _placeholderTimer;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _placeholderTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startPlaceholderAnimation();
  }

  void _startPlaceholderAnimation() {
    if (_textController.text.isEmpty) {
      _placeholderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted && _textController.text.isEmpty) {
          setState(() {
            _currentPlaceholderIndex =
                (_currentPlaceholderIndex + 1) % _placeholderTexts.length;
          });
        }
      });
    }
  }

  void _stopPlaceholderAnimation() {
    _placeholderTimer?.cancel();
  }

  bool _shouldShowPlaceholder() {
    return _textController.text.isEmpty && !_isImageMode;
  }

  String _getCurrentPlaceholder() {
    return _placeholderTexts[_currentPlaceholderIndex];
  }

  // Text validation logic
  bool _isTextValid(String text) {
    if (text.length < 20) return false;

    // Check if text contains at least one alphabet character
    return text.contains(RegExp(r'[a-zA-Z]'));
  }

  String? _getValidationMessage() {
    if (_isImageMode && _extractedText != null) {
      // For OCR input, just check if text was extracted (URLs are ignored)
      if (_extractedText!.isEmpty) {
        return 'Could not extract meaningful text from image';
      }
      return null;
    }

    if (_textController.text.isEmpty) {
      return null;
    }

    return _getValidationMessageForInput(_textController.text);
  }

  bool _canSubmit() {
    if (_isImageMode) {
      // For OCR input, just check if text was extracted (URLs are ignored)
      return _extractedText != null && _extractedText!.isNotEmpty;
    }

    // For direct text input, validate input type
    final inputType = _detectInputType(_textController.text);
    return inputType != InputType.invalid;
  }

  void _onTextChanged() {
    setState(() {
      if (_textController.text.isNotEmpty) {
        _currentState = _canSubmit()
            ? DetectionState.validInput
            : DetectionState.idle;
      } else {
        _currentState = DetectionState.idle;
        // Resume animation when text is cleared
        _startPlaceholderAnimation();
      }
      _errorMessage = null;
    });
  }

  // Input type detection and URL validation
  InputType _detectInputType(String text) {
    // Check if text contains a URL
    final urlPattern = RegExp(
      r'https?://[^\s/$.?#].[^\s]*|www\.[^\s/$.?#].[^\s]*',
      caseSensitive: false,
    );

    final matches = urlPattern.allMatches(text);
    if (matches.isNotEmpty) {
      // Check if there's exactly one URL
      if (matches.length == 1) {
        final url = matches.first.group(0)!;
        if (_isValidUrl(url)) {
          return InputType.url;
        }
      }
      return InputType.invalid; // Multiple URLs or invalid URL
    }

    // Check if it's valid text for phishing detection
    if (_isTextValid(text)) {
      return InputType.text;
    }

    return InputType.invalid;
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url.startsWith('www.') ? 'https://$url' : url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String? _getValidationMessageForInput(String text) {
    final inputType = _detectInputType(text);

    switch (inputType) {
      case InputType.url:
        return null; // URL is valid
      case InputType.text:
        return null; // Text is valid
      case InputType.invalid:
        if (text.isEmpty) return null;

        // Check for multiple URLs
        final urlPattern = RegExp(
          r'https?://[^\s/$.?#].[^\s]*|www\.[^\s/$.?#].[^\s]*',
          caseSensitive: false,
        );
        final matches = urlPattern.allMatches(text);
        if (matches.length > 1) {
          return 'Multiple URLs detected. Please enter a single URL.';
        }

        // Check for invalid URL
        if (matches.isNotEmpty && !_isValidUrl(matches.first.group(0)!)) {
          return 'Invalid URL format. Please enter a valid http/https URL.';
        }

        // Check text validation
        if (text.length < 20) {
          return 'Text must be at least 20 characters long for phishing detection.';
        }

        if (!text.contains(RegExp(r'[a-zA-Z]'))) {
          return 'Text must contain at least one alphabet character for phishing detection.';
        }

        return 'Invalid input format.';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);

        // Check file size (5MB limit)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          setState(() {
            _errorMessage = 'Image size must be less than 5MB';
          });
          return;
        }

        // Check file type
        final fileName = image.path.toLowerCase();
        if (!fileName.endsWith('.png') &&
            !fileName.endsWith('.jpg') &&
            !fileName.endsWith('.jpeg')) {
          setState(() {
            _errorMessage = 'Only PNG, JPG, and JPEG images are allowed';
          });
          return;
        }

        setState(() {
          _selectedImage = file;
          _isImageMode = true;
          _textController.clear();
          _extractedText = null;
          _detectionResult = null;
          _currentState = DetectionState.loading;
          _errorMessage = null;
        });

        await _extractTextFromImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
        _currentState = DetectionState.error;
      });
    }
  }

  Future<void> _extractTextFromImage() async {
    try {
      final inputImage = InputImage.fromFilePath(_selectedImage!.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();

      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      final extractedText = recognizedText.text.trim();

      setState(() {
        _extractedText = extractedText;
        // For OCR input, just check if text was extracted (URLs are ignored)
        if (extractedText.isNotEmpty) {
          _currentState = DetectionState.validInput;
        } else {
          _currentState = DetectionState.error;
          _errorMessage = 'Could not extract meaningful text from image';
        }
      });
    } catch (e) {
      setState(() {
        _currentState = DetectionState.error;
        _errorMessage = 'Failed to extract text from image: ${e.toString()}';
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _extractedText = null;
      _isImageMode = false;
      _currentState = DetectionState.idle;
      _errorMessage = null;
    });
  }

  Future<void> _scanUrl(String url) async {
    setState(() {
      _currentState = DetectionState.loading;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://qr-url-detector-mc17.onrender.com/scan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );

      if (response.statusCode == 200) {
        final result = URLDetectionResult.fromJson(json.decode(response.body));
        setState(() {
          _urlDetectionResult = result;
          _currentState = DetectionState.result;
        });

        // Scroll to show result
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } else {
        setState(() {
          _currentState = DetectionState.error;
          _errorMessage = 'URL analysis failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _currentState = DetectionState.error;
        _errorMessage =
            'Network error. Please check your connection and try again.';
      });
    }
  }

  Future<void> _analyzeText() async {
    final textToAnalyze = _isImageMode ? _extractedText! : _textController.text;
    final inputSource = _isImageMode ? InputSource.imageOcr : InputSource.text;

    // Clear previous results
    setState(() {
      _detectionResult = null;
      _urlDetectionResult = null;
    });

    // Route based on input source first, then input type
    switch (inputSource) {
      case InputSource.text:
        // Direct text input - check for URL first
        final inputType = _detectInputType(textToAnalyze);
        switch (inputType) {
          case InputType.url:
            // Extract URL and scan it
            final urlPattern = RegExp(
              r'https?://[^\s/$.?#].[^\s]*|www\.[^\s/$.?#].[^\s]*',
              caseSensitive: false,
            );
            final match = urlPattern.firstMatch(textToAnalyze);
            if (match != null) {
              String url = match.group(0)!;
              if (url.startsWith('www.')) {
                url = 'https://$url';
              }
              await _scanUrl(url);
            }
            break;

          case InputType.text:
            await _analyzePhishingText(textToAnalyze);
            break;

          case InputType.invalid:
            setState(() {
              _currentState = DetectionState.error;
              _errorMessage =
                  _getValidationMessageForInput(textToAnalyze) ??
                  'Invalid input format.';
            });
            break;
        }
        break;

      case InputSource.imageOcr:
        // OCR input - ALWAYS use phishing detection, ignore URLs
        await _analyzePhishingText(textToAnalyze);
        break;
    }
  }

  Future<void> _analyzePhishingText(String text) async {
    setState(() {
      _currentState = DetectionState.loading;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://phishing-detection-model.onrender.com/analyze-text'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 200) {
        final result = FraudDetectionResult.fromJson(
          json.decode(response.body),
        );
        setState(() {
          _detectionResult = result;
          _currentState = DetectionState.result;
        });

        // Scroll to show result
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _currentState = DetectionState.error;
          _errorMessage =
              errorData['detail'] ?? 'Analysis failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _currentState = DetectionState.error;
        _errorMessage =
            'Network error. Please check your connection and try again.';
      });
    }
  }

  void _resetAnalysis() {
    setState(() {
      _detectionResult = null;
      _urlDetectionResult = null;
      _currentState = _canSubmit()
          ? DetectionState.validInput
          : DetectionState.idle;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryText(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detect Fraud',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Result Card
                  if (_detectionResult != null) ...[
                    _buildPhishingResultCard(),
                    const SizedBox(height: 20),
                  ],
                  if (_urlDetectionResult != null) ...[
                    _buildUrlResultCard(),
                    const SizedBox(height: 20),
                  ],

                  // Image Preview (if image is selected)
                  if (_selectedImage != null) ...[
                    _buildImagePreview(),
                    const SizedBox(height: 16),
                  ],

                  // Error Message
                  if (_errorMessage != null) ...[
                    _buildErrorMessage(),
                    const SizedBox(height: 16),
                  ],

                  // Loading Indicator
                  if (_currentState == DetectionState.loading) ...[
                    _buildLoadingIndicator(),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // Input Section
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildPhishingResultCard() {
    final isPhishing = _detectionResult!.status == 'phishing';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPhishing
            ? AppColors.dangerBg(context)
            : AppColors.successBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPhishing
              ? AppColors.dangerRed.withValues(alpha: 0.3)
              : AppColors.successGreen.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPhishing
                      ? AppColors.dangerRed.withValues(alpha: 0.1)
                      : AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPhishing
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  color: isPhishing
                      ? AppColors.dangerRed
                      : AppColors.successGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPhishing ? 'Phishing Detected' : 'Legitimate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isPhishing
                            ? AppColors.dangerRed
                            : AppColors.successGreen,
                      ),
                    ),
                    Text(
                      '${(_detectionResult!.confidence > 100 ? _detectionResult!.confidence / 100 : _detectionResult!.confidence).toStringAsFixed(1)}% confidence',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _resetAnalysis,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.mutedText(context),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _detectionResult!.explanation,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryText(context),
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlResultCard() {
    final isSafe = _urlDetectionResult!.verdict.toLowerCase() == 'safe';
    final isSuspicious =
        _urlDetectionResult!.verdict.toLowerCase() == 'suspicious';

    Color cardColor, iconColor, textColor;
    IconData iconData;

    if (isSafe) {
      cardColor = AppColors.successBg(context);
      iconColor = AppColors.successGreen;
      textColor = AppColors.successGreen;
      iconData = Icons.check_circle_rounded;
    } else if (isSuspicious) {
      cardColor = AppColors.warningBg(context);
      iconColor = AppColors.warningYellow;
      textColor = AppColors.warningYellow;
      iconData = Icons.warning_rounded;
    } else {
      cardColor = AppColors.dangerBg(context);
      iconColor = AppColors.dangerRed;
      textColor = AppColors.dangerRed;
      iconData = Icons.dangerous_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _urlDetectionResult!.verdict,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    Text(
                      _urlDetectionResult!.riskScore,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _resetAnalysis,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.mutedText(context),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_urlDetectionResult!.reasons.isNotEmpty) ...[
            Text(
              'Analysis Reasons:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            ..._urlDetectionResult!.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                        color: textColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryText(context),
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Image',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText(context),
                ),
              ),
              IconButton(
                onPressed: _clearImage,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.mutedText(context),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          if (_extractedText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extracted Text:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _extractedText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryText(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.dangerRed.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.dangerRed,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.dangerRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        CircularProgressIndicator(color: AppColors.primaryBlue, strokeWidth: 3),
        const SizedBox(height: 16),
        Text(
          'Analyzing content...',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryText(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Validation Helper Text
          if (!_isImageMode &&
              _textController.text.isNotEmpty &&
              _getValidationMessage() != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _getValidationMessage()!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.warningYellow,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          Row(
            children: [
              // Image Picker Button
              GestureDetector(
                onTap: _currentState == DetectionState.loading
                    ? null
                    : _pickImage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _currentState == DetectionState.loading
                        ? AppColors.disabledColor(context)
                        : AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ),
              ),

              const SizedBox(width: 12),

              // Text Input Field
              Expanded(
                child: Stack(
                  children: [
                    TextField(
                      controller: _textController,
                      enabled:
                          !_isImageMode &&
                          _currentState != DetectionState.loading,
                      onChanged: (value) {
                        _onTextChanged();
                        // Stop animation when user starts typing
                        if (value.isNotEmpty) {
                          _stopPlaceholderAnimation();
                        } else {
                          // Resume animation when field is cleared
                          _startPlaceholderAnimation();
                        }
                      },
                      onTap: () {
                        // Stop animation when field is focused
                        if (_textController.text.isEmpty) {
                          _stopPlaceholderAnimation();
                        }
                      },
                      onEditingComplete: () {
                        // Resume animation when editing is complete and field is empty
                        if (_textController.text.isEmpty) {
                          _startPlaceholderAnimation();
                        }
                      },
                      maxLines: 3,
                      minLines: 1,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: _isImageMode ? 'Image selected' : null,
                        hintStyle: TextStyle(
                          color: AppColors.mutedText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: _isImageMode
                            ? AppColors.disabledColor(context)
                            : AppColors.bg(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.borderColor(context),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.borderColor(context),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Animated placeholder overlay
                    if (_shouldShowPlaceholder())
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                _getCurrentPlaceholder(),
                                key: ValueKey(_getCurrentPlaceholder()),
                                style: TextStyle(
                                  color: AppColors.mutedText(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Send Button
              GestureDetector(
                onTap: (_canSubmit() && _currentState != DetectionState.loading)
                    ? _analyzeText
                    : null,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        (_canSubmit() &&
                            _currentState != DetectionState.loading)
                        ? AppColors.primaryBlue
                        : AppColors.disabledColor(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _currentState == DetectionState.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
