import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (_isProcessing) return;

    final barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Stop the scanner
    _controller.stop();

    // Process the scanned data
    _processScannedData(barcode.rawValue!);
  }

  Future<void> _processScannedData(String data) async {
    // Check if it's a UPI payment QR code
    if (data.startsWith('upi://pay?')) {
      _handleUpiPayment(data);
    } 
    // Check if it's a URL
    else if (Uri.tryParse(data)?.hasAbsolutePath ?? false) {
      await _handleUrl(data);
      return;
    }
    // Handle any other text content
    else {
      _handleTextContent(data);
    }
  }

  Future<void> _showUrlScanDialog({
    required String url,
    required String verdict,
    required String riskScore,
    required String reasons,
  }) async {
    final bool isSafe = verdict.toLowerCase() == 'safe';
    final Color statusColor = isSafe ? Colors.green : Colors.orange;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: Row(
            children: [
              Icon(
                isSafe ? Icons.check_circle : Icons.warning_amber_rounded,
                color: statusColor,
              ),
              const SizedBox(width: 10),
              Text(
                'URL Scan Results',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  url,
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        verdict.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Risk: $riskScore',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Analysis:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• $reasons',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close scanner
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close both dialog and scanner screen first
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close scanner
                
                // Then open the URL
                try {
                  // Ensure URL has a scheme
                  String urlToLaunch = url;
                  if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
                    urlToLaunch = 'https://$urlToLaunch';
                  }
                  
                  final uri = Uri.parse(urlToLaunch);
                  
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    print('Successfully launched URL: $urlToLaunch');
                  } else {
                    print('Could not launch URL: $urlToLaunch');
                    // Fallback to web view if external app fails
                    await launchUrl(
                      uri,
                      mode: LaunchMode.inAppWebView,
                    );
                  }
                } catch (e) {
                  print('Error launching URL: $e');
                  // Show error to user
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open URL: $url'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('PROCEED'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUrl(String url) async {
    if (!mounted) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Make an API call to the provided URL scanning service
      final response = await http.post(
        Uri.parse('https://qr-url-detector-mc17.onrender.com/scan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final verdict = responseData['verdict']?.toString() ?? 'Unknown';
        final riskScore = responseData['risk_score']?.toString() ?? 'N/A';
        final reasons = responseData['reasons'] is List 
            ? (responseData['reasons'] as List).map((e) => e.toString()).join('\n• ')
            : 'No additional information';
        
        if (mounted) {
          await _showUrlScanDialog(
            url: url,
            verdict: verdict,
            riskScore: riskScore,
            reasons: reasons,
          );
        }
      } else {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: const Text(
              'Scan Failed',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Failed to scan URL. Status: ${response.statusCode}\n${response.body}',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Text(
            'Error',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Error scanning URL: $e',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _controller.start();
      }
    }
  }

  void _handleTextContent(String text) {
    // Return any other text content
    Navigator.pop(context, {
      'type': 'text',
      'content': text,
    });
  }

  void _handleUpiPayment(String upiPayload) {
    // Parse UPI payload
    // Format: upi://pay?pa=<upi_id>&pn=<name>&cu=INR
    try {
      final uri = Uri.parse(upiPayload);
      final upiId = uri.queryParameters['pa'];
      final name = uri.queryParameters['pn'];

      if (upiId == null || name == null) {
        _showError('Invalid UPI QR code format');
        return;
      }

      // Navigate to payment screen with parsed data
      Navigator.pop(context, {
        'upiId': upiId,
        'name': Uri.decodeComponent(name),
        'payload': upiPayload,
      });
    } catch (e) {
      _showError('Error parsing QR code: $e');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          'Error',
          style: TextStyle(color: AppColors.primaryText(context)),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.secondaryText(context)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
              });
              _controller.start();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),

          // Overlay with scan area border
          _buildScannerOverlay(),

          // Instructions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Position the QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanAreaSize) / 2;
        final top = (constraints.maxHeight - scanAreaSize) / 2 - 50;

        return Stack(
          children: [
            // Semi-transparent overlay
            Positioned.fill(
              child: CustomPaint(
                painter: ScannerOverlayPainter(
                  scanArea: Rect.fromLTWH(
                    left,
                    top,
                    scanAreaSize,
                    scanAreaSize,
                  ),
                ),
              ),
            ),

            // Corner borders
            Positioned(
              left: left,
              top: top,
              child: CustomPaint(
                size: Size(scanAreaSize, scanAreaSize),
                painter: CornerBorderPainter(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanArea;

  ScannerOverlayPainter({required this.scanArea});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanArea)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CornerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(0, cornerLength),
      Offset(0, 0),
      paint,
    );
    canvas.drawLine(
      Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

