import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'account_selection_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String name;
  final String upiId;

  const PaymentScreen({
    super.key,
    required this.name,
    required this.upiId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _amount = "";

  // Strictly maintained avatar logic from Home Screen
  static const Color primaryBlue = Color(0xFF2563EB);
  static const List<Color> avatarColors = [
    primaryBlue,
    Color(0xFF4F46E5),
    Color(0xFF0891B2),
    Color(0xFF7C3AED),
  ];

  void _onKeyPress(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      if (value == 'backspace') {
        if (_amount.isNotEmpty) _amount = _amount.substring(0, _amount.length - 1);
      } else if (_amount.length < 9) {
        if (value == '.' && _amount.contains('.')) return;
        if (_amount.isEmpty && value == '.') _amount = "0";
        _amount += value;
      }
    });
  }

  Color _getAvatarColor() {
    final int hash = widget.name.toLowerCase().hashCode;
    return avatarColors[hash.abs() % avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Decorative background glow for a "Creative" look
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: avatarColor.withOpacity(0.05),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),

                // Content area that centers everything between top bar and numpad
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHomeStyleAvatar(avatarColor),
                          const SizedBox(height: 24),
                          _buildAmountDisplay(),
                          const SizedBox(height: 12),
                          _buildNoteSection(),
                        ],
                      ),
                    ),
                  ),
                ),

                _buildCompactNumpad(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryText(context), size: 20),
          ),
          Text(
            "TRANSFER",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText(context),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHomeStyleAvatar(Color currentBg) {
    final String firstLetter = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?';

    return Column(
      children: [
        // Exact Trusted Contact Squircle Avatar UI
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: currentBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: currentBg.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ghost letter for creative depth
              Positioned(
                right: -5,
                bottom: -5,
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Main foreground letter
              Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ).animate().scale(curve: Curves.easeOutBack, duration: 500.ms),

        const SizedBox(height: 16),

        Text(
          widget.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText(context),
          ),
        ),
        Text(
          widget.upiId,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText(context),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountDisplay() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "₹",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _amount.isEmpty ? "0" : _amount,
              style: TextStyle(
                fontSize: _amount.length > 5 ? 42 : 56,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryText(context),
                letterSpacing: -1,
              ),
            ).animate(target: _amount.isEmpty ? 0 : 1).shimmer(duration: 1.seconds),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_rounded, size: 12, color: AppColors.successGreen),
            SizedBox(width: 4),
            Text(
              "SECURE UPI TRANSACTION",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.successGreen, letterSpacing: 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondarySurface(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_comment_rounded, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            "Add message",
            style: TextStyle(fontSize: 13, color: AppColors.secondaryText(context), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNumpad() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.6,
            children: [
              ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'backspace']
                  .map((val) => _numpadKey(val, isIcon: val == 'backspace')),
            ],
          ),
          const SizedBox(height: 16),
          _buildProceedButton(),
        ],
      ),
    );
  }

  Widget _numpadKey(String label, {bool isIcon = false}) {
    return InkWell(
      onTap: () => _onKeyPress(label),
      borderRadius: BorderRadius.circular(16),
      child: Center(
        child: isIcon
            ? Icon(Icons.backspace_outlined, color: AppColors.primaryText(context), size: 22)
            : Text(
          label,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primaryText(context)),
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    bool enabled = _amount.isNotEmpty && _amount != "0" && _amount != ".";
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        onPressed: !enabled ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccountSelectionScreen(
                name: widget.name,
                upiId: widget.upiId,
                amount: _amount,
              ),
            ),
          );
        },
        child: Text(
          "Proceed to Pay",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
        ),
      ),
    );
  }
}