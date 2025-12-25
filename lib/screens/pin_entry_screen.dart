import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_colors.dart';
import 'package:heisenbug/screens/payment_success_screen.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';

class PinEntryScreen extends StatefulWidget {
  final String amount;
  final String bankName;
  final String recipientName;
  final String recipientUpiId;

  const PinEntryScreen({
    super.key,
    required this.amount,
    required this.bankName,
    required this.recipientName,
    required this.recipientUpiId,
  });

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _pin = "";
  bool _isProcessing = false;
  String? _errorMessage;
  late final SupabaseService _supabaseService;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
  }

  // --- Logic remains optimized for your backend ---
  Future<void> _processPayment() async {
    if (_pin.length != 4) return;
    HapticFeedback.mediumImpact();
    setState(() { _isProcessing = true; _errorMessage = null; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('logged_in_phone');
      if (phoneNumber == null) throw 'Session Expired';

      final user = await _supabaseService.getUserByPhone(phoneNumber);
      if (user?.pin != _pin) {
        throw 'Invalid UPI PIN';
      }

      final transaction = await _supabaseService.processPayment(
        userId: user!.userId!,
        receiverUpi: widget.recipientUpiId,
        amount: double.parse(widget.amount),
        deviceId: _uuid.v4(),
        location: null,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              amount: widget.amount,
              recipient: widget.recipientName, // Matches 'recipient' in PaymentSuccessScreen
              transactionId: transaction.utrReference ?? 'TXN${DateTime.now().millisecondsSinceEpoch}',
              timestamp: transaction.createdAt ?? DateTime.now(),
            ),
          ),

        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
        _pin = '';
      });
      HapticFeedback.vibrate();
    }
  }

  void _onKeyPress(String value) {
    if (_isProcessing) return;
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      if (value == 'backspace') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (value == 'submit') {
        if (_pin.length == 4) _processPayment();
      } else if (_pin.length < 4) {
        _pin += value;
        if (_pin.length == 4) {
          Future.delayed(const Duration(milliseconds: 300), _processPayment);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.bankName.toUpperCase(),
          style: TextStyle(color: AppColors.primaryText(context), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 110),
              _buildTransactionCard(),
              const Spacer(),
              _buildSecurityIndicator(),
              const SizedBox(height: 20),
              _buildPinDisplay(),
              const Spacer(),
              _buildModernNumpad(),
            ],
          ),
          if (_isProcessing) _buildOverlayLoader(),
        ],
      ),
    );
  }

  Widget _buildTransactionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.secondarySurface(context)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_rounded, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PAYING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.mutedText(context), letterSpacing: 1)),
                  Text(widget.recipientName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryText(context))),
                ],
              ),
            ),
            Text('₹${widget.amount}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildSecurityIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.successGreen),
        const SizedBox(width: 8),
        Text(
          '256-BIT END-TO-END ENCRYPTED',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.successGreen, letterSpacing: 1),
        ),
      ],
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds);
  }

  Widget _buildPinDisplay() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            bool filled = index < _pin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 14),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: filled ? AppColors.primaryBlue : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: filled ? AppColors.primaryBlue : AppColors.secondarySurface(context),
                  width: 2,
                ),
                boxShadow: filled ? [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.5), blurRadius: 10)] : [],
              ),
            ).animate(target: filled ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2));
          }),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)).animate().shake(),
          ),
      ],
    );
  }

  Widget _buildModernNumpad() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))],
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          ...List.generate(9, (index) => _numpadKey('${index + 1}')),
          _numpadKey('backspace', isIcon: true),
          _numpadKey('0'),
          _numpadKey('submit', isIcon: true, isAction: true),
        ],
      ),
    );
  }

  Widget _numpadKey(String val, {bool isIcon = false, bool isAction = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(val),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isAction ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: isIcon
                ? Icon(
              val == 'backspace' ? Icons.backspace_outlined : Icons.check_rounded,
              color: isAction ? Colors.white : AppColors.primaryText(context),
              size: 28,
            )
                : Text(
              val,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primaryText(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayLoader() {
    return Container(
      color: Colors.black54,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
              const SizedBox(height: 24),
              const Text('SECURELY PROCESSING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}