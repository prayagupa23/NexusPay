// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language_preference.dart';
import '../models/message_model.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'money_screen.dart';
import 'package:heisenbug/services/fraud_detection_services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FraudDetectionService _fraudService = FraudDetectionService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  late FlutterTts _flutterTts;

  List<Message> _messages = [];
  bool _isTyping = false;
  bool _isListening = false;
  String _lastWords = '';
  bool _hasRequestedPermission = false;
  bool _isSpeaking = false;
  
  // Language preference
  late LanguagePreference _selectedLanguage;
  bool _showLanguageOptions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initTts();
    _loadLanguagePreference();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSpeech();
      // Speak the welcome message
      _speak("Hello! Staying safe online starts with awareness.");
    });
    _messages.add(Message.bot(
        "Hello! Staying safe online starts with awareness."));
  }
  
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selected_language') ?? 'en';
    setState(() {
      _selectedLanguage = LanguagePreference.fromCode(languageCode);
    });
    
    // Update TTS language if needed
    if (_selectedLanguage.code != 'en') {
      await _flutterTts.setLanguage('en-${_selectedLanguage.code.toUpperCase()}');
    }
  }
  
  Future<void> _changeLanguage(LanguagePreference newLanguage) async {
    if (newLanguage.code == _selectedLanguage.code) {
      setState(() => _showLanguageOptions = false);
      return;
    }
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', newLanguage.code);
    
    // Update UI and TTS
    setState(() {
      _selectedLanguage = newLanguage;
      _showLanguageOptions = false;
    });
    
    // Update TTS language if needed
    if (newLanguage.code != 'en') {
      await _flutterTts.setLanguage('en-${newLanguage.code.toUpperCase()}');
    }
    
    // Notify user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to ${newLanguage.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopSpeaking();
    _speech.stop();
    _controller.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // When app goes to background
      _stopSpeaking();
      _speech.stop();
    } else if (state == AppLifecycleState.resumed) {
      // When app comes back to foreground
      _initTts();
    }
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    
    // Set TTS settings
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    
    // Set up TTS completion handler
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      setState(() => _isSpeaking = false);
    });
  }
  
  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    
    try {
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(text);
    } catch (e) {
      print("Error in _speak: $e");
      setState(() => _isSpeaking = false);
    }
  }
  
  Future<void> _stopSpeaking() async {
    try {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } catch (e) {
      print("Error stopping TTS: $e");
    }
  }

  void _initSpeech() async {
    print('Initializing speech recognition...');
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech recognition status: $status');
          setState(() {
            _isListening = status == stt.SpeechToText.listeningStatus;
          });
        },
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            _isListening = false;
          });
          // Show error to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech recognition error: $error')),
          );
        },
      );
      
      print('Speech recognition available: $available');
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available on this device')),
        );
      }
    } catch (e) {
      print('Error initializing speech recognition: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize speech recognition: $e')),
      );
    }
  }

  Future<bool> _checkAndRequestPermission() async {
    // First check if we already have permission
    var status = await Permission.microphone.status;
    print('Current microphone permission status: $status');
    
    if (status.isDenied) {
      // Show a dialog explaining why we need the permission
      if (!_hasRequestedPermission) {
        _hasRequestedPermission = true;
        
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Microphone Permission'),
            content: const Text(
              'DigiGuard needs access to your microphone to enable voice input. This allows you to speak your messages instead of typing them.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Now'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );

        if (shouldContinue != true) {
          return false;
        }
      }
      
      // Request the permission
      status = await Permission.microphone.request();
      print('After requesting, permission status: $status');
      
      if (status.isPermanentlyDenied) {
        // The user opted to never again see the permission request dialog
        if (mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'Microphone permission is required for voice input. Please enable it in your device settings.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await openAppSettings();
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return false;
      }
    }
    
    // If we have permission, initialize the speech recognition
    if (status.isGranted) {
      final hasSpeech = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );
      return hasSpeech;
    }
    
    return false;
  }

  void _startListening() async {
    print('Start listening called. Current listening state: $_isListening');
    
    if (!_isListening) {
      try {
        // Check and request permission if needed
        final hasPermission = await _checkAndRequestPermission();
        if (!hasPermission) {
          print('Speech recognition permission not granted');
          setState(() => _isListening = false);
          return;
        }

        setState(() {
          _isListening = true;
          _lastWords = '';
        });

        bool started = await _speech.listen(
          onResult: (result) {
            print('Speech recognition result: ${result.recognizedWords}');
            setState(() {
              _lastWords = result.recognizedWords;
              _controller.text = _lastWords;
              
              if (result.finalResult) {
                print('Final result received, sending message...');
                _handleSendMessage();
              }
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          localeId: 'en_IN', // Try with Indian English locale
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        );
        
        print('Speech recognition started: $started');
        if (!started) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not start speech recognition')),
          );
        }
      } catch (e) {
        print('Error in _startListening: $e');
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      print('Stopping speech recognition...');
      try {
        await _speech.stop();
        setState(() => _isListening = false);
        
        if (_lastWords.isNotEmpty) {
          _controller.text = _lastWords;
          _handleSendMessage();
        }
      } catch (e) {
        print('Error stopping speech recognition: $e');
      }
    }
  }

  // dispose() is already defined earlier in the class with WidgetsBinding observer cleanup

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;
    
    // Create a copy of the message for the API call
    String apiMessage = userMessage;
    
    // Append language instruction to API message if not English
    if (_selectedLanguage.code != 'en') {
      apiMessage = '$userMessage\n\n${_selectedLanguage.instruction}';
    }

    // Add original message to chat UI
    setState(() {
      _messages.add(Message.user(userMessage));
      _isTyping = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      // Send the API message (with language instruction if needed) to Gemini API
      final response = await _fraudService.analyzeFraudRisk(apiMessage);
      
      if (mounted) {
        setState(() {
          _messages.add(Message.bot(response));
          _isTyping = false;
        });
        _scrollToBottom();
        // Speak the bot's response
        _speak(response);
      }
    } catch (e) {
      final errorMessage = "Sorry, I encountered an error. Please try again later.";
      if (mounted) {
        setState(() {
          _messages.add(Message.bot(errorMessage));
          _isTyping = false;
        });
        _scrollToBottom();
        _speak(errorMessage);
      }
    }
  }

  // _speak() and _stopSpeaking() are already defined earlier in the class

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryText(context),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shield_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Awareness Bot',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language selector button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Text(
                _selectedLanguage.flag,
                style: const TextStyle(fontSize: 24),
              ),
              onPressed: () {
                setState(() {
                  _showLanguageOptions = !_showLanguageOptions;
                });
              },
              tooltip: 'Change language',
            ),
          ),
          // More options button
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.primaryText(context),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_showLanguageOptions) {
            setState(() => _showLanguageOptions = false);
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        return _buildMessageBubble(_messages[index], isDark);
                      } else {
                        return _buildTypingIndicator(isDark);
                      }
                    },
                  ),
                ),
                _buildInputArea(isDark),
              ],
            ),
            
            if (_showLanguageOptions)
              Positioned(
                top: kToolbarHeight + 4,
                right: 16,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Select Language',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ...LanguagePreference.supportedLanguages.map((language) {
                          return ListTile(
                            dense: true,
                            leading: Text(
                              language.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            title: Text(language.name),
                            trailing: _selectedLanguage.code == language.code
                                ? const Icon(Icons.check, color: Colors.blue)
                                : null,
                            onTap: () => _changeLanguage(language),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MoneyScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isDark) {
    final isBot = !message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surface(context),
              child: Icon(
                Icons.shield_rounded,
                size: 20,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isBot
                    ? AppColors.surface(context)
                    : AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isBot ? const Radius.circular(4) : null,
                  bottomRight: !isBot ? const Radius.circular(4) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBot)
                    Text(
                      "DigiGuard AI",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  if (isBot) const SizedBox(height: 4),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isBot
                          ? AppColors.primaryText(context)
                          : Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isBot) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange.shade300,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                color: Colors.orange.shade700,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surface(context),
            child: Icon(
              Icons.shield_rounded,
              size: 20,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSpeaking)
                  GestureDetector(
                    onTap: _stopSpeaking,
                    child: Icon(
                      Icons.volume_off_rounded,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                  )
                else
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  _isSpeaking ? "Speaking..." : "Typing...",
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.secondarySurface(context).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Microphone button
          GestureDetector(
            onTap: _startListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isListening 
                  ? Colors.red.withOpacity(0.2)
                  : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                color: _isListening 
                  ? Colors.red 
                  : AppColors.primaryText(context).withOpacity(0.7),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text input field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSecondarySurface
                    : AppColors.lightSecondarySurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: _isListening ? "Listening..." : "Ask about a threat or scam...",
                  hintStyle: TextStyle(
                    color: _isListening 
                      ? AppColors.primaryBlue 
                      : AppColors.mutedText(context),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: _handleSendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _controller.text.trim().isNotEmpty 
                  ? AppColors.primaryBlue 
                  : AppColors.primaryBlue.withOpacity(0.5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _controller.text.trim().isNotEmpty
                      ? AppColors.primaryBlue.withOpacity(0.3)
                      : Colors.transparent,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
