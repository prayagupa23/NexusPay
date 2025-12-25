import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String amount;
  final String recipient;
  final String transactionId;
  final DateTime timestamp;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.recipient,
    required this.transactionId,
    required this.timestamp,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // High-precision haptic feedback for a "solid" feel
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = '${widget.timestamp.day}/${widget.timestamp.month}/${widget.timestamp.year}';
    final formattedTime =
        '${widget.timestamp.hour}:${widget.timestamp.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildFormalTick(),
                    const SizedBox(height: 40),
                    _buildAmountSection(),
                    const SizedBox(height: 40),
                    _buildTransactionTable(formattedDate, formattedTime),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        "TRANSACTION RECEIPT",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          color: AppColors.secondaryText(context),
        ),
      ),
    );
  }

  Widget _buildFormalTick() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer rigid ring
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.successGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOut),

        // Inner check - Fixed "backOut" by using easeOut (Formal)
        Icon(
          Icons.check_circle_rounded,
          color: AppColors.successGreen,
          size: 80,
        ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      children: [
        Text(
          "₹ ${widget.amount}",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText(context),
            letterSpacing: -1,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 16, color: AppColors.successGreen),
            const SizedBox(width: 8),
            Text(
              "SENT TO ${widget.recipient.toUpperCase()}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryText(context),
                letterSpacing: 1,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildTransactionTable(String date, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondarySurface(context)),
      ),
      child: Column(
        children: [
          _buildInfoRow("Reference Number", widget.transactionId),
          _divider(),
          _buildInfoRow("Status", "Success", isStatus: true),
          _divider(),
          _buildInfoRow("Date", date),
          _divider(),
          _buildInfoRow("Time", time),
        ],
      ),
    ).animate().slideY(begin: 0.1, end: 0, delay: 600.ms).fadeIn();
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isStatus ? AppColors.successGreen : AppColors.primaryText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 24, color: AppColors.secondarySurface(context), thickness: 0.5);

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            "CONTINUE",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}