// lib/screens/chat_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/message_model.dart';
import '../theme/app_colors.dart';
import 'package:heisenbug/services/fraud_detection_services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FraudDetectionService _fraudService = FraudDetectionService();

  AnimationController? _scanController;
  List<Message> _messages = [];
  bool _isTyping = false;
  double _threatLevel = 0.10; // 0.0 to 1.0

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _messages.add(Message.bot("Aegis Neural Link: Active. I am monitoring for UPI scams, KYC fraud, and suspicious links. How can I help?"));
  }

  @override
  void dispose() {
    _scanController?.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(Message.user(text));
      _isTyping = true;
    });
    _scrollToBottom();

    // Trigger Gemini Fraud Analysis
    final aiResponse = await _fraudService.analyzeFraudRisk(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(Message.bot(aiResponse));

        // Dynamic Threat Logic: Increase meter if AI detects danger
        if (aiResponse.toLowerCase().contains("dangerous") || aiResponse.toLowerCase().contains("suspicious")) {
          _threatLevel = 0.85;
        } else {
          _threatLevel = 0.15;
        }
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          _buildAmbientGlow(isDark),
          _buildScanLine(),

          Column(
            children: [
              _buildModernHeader(context),
              _buildThreatConsole(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) return _buildTypingState();
                    return _buildNeuralBubble(_messages[index], isDark);
                  },
                ),
              ),
              _buildInputArea(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 15, left: 10, right: 10),
          decoration: BoxDecoration(
            color: AppColors.surface(context).withOpacity(0.7),
            border: Border(bottom: BorderSide(color: Colors.blue.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AEGIS INTELLIGENCE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
                  Text("ENCRYPTED DATA NODE", style: TextStyle(fontSize: 8, color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.security_outlined, color: Colors.blue, size: 20),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreatConsole() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("NEURAL RISK SCAN", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text("${(_threatLevel * 100).toInt()}% RISK",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: _threatLevel > 0.7 ? Colors.red : Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _threatLevel,
              minHeight: 3,
              backgroundColor: Colors.blue.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_threatLevel > 0.7 ? Colors.red : Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuralBubble(Message message, bool isDark) {
    bool isBot = !message.isUser;
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isBot ? AppColors.surface(context) : const Color(0xFF1A56DB),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isBot ? const Radius.circular(0) : null,
            bottomRight: !isBot ? const Radius.circular(0) : null,
          ),
          border: Border.all(color: isBot ? Colors.blue.withOpacity(0.1) : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBot) ...[
              const Text("AEGIS_AI >>", style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
            ],
            Text(
              message.text,
              style: TextStyle(color: isBot ? AppColors.primaryText(context) : Colors.white, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 35),
      decoration: BoxDecoration(color: AppColors.surface(context)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Paste suspicious message or link...",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSendMessage,
            child: Container(
              height: 50, width: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanLine() {
    if (_scanController == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _scanController!,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * _scanController!.value,
          left: 0, right: 0,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, Colors.blue.withOpacity(0.3), Colors.transparent]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmbientGlow(bool isDark) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.blue.withOpacity(isDark ? 0.03 : 0.01), Colors.transparent],
            radius: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingState() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Shimmer.fromColors(
        baseColor: Colors.blue.withOpacity(0.3),
        highlightColor: Colors.white,
        child: const Text("ANALYZING NEURAL DATA...", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }
}
