import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'feature_carousel.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensuring status bar matches the premium aesthetic
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildBrandMark(context),
                        const SizedBox(height: 32),

                        _buildHeroText(context),
                        const SizedBox(height: 16),

                        const SizedBox(height: 32),

                        _buildFeatureGrid(context),
                        const Spacer(),

                        _buildActionButtons(context),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandMark(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        size: 38,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildHeroText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Banking.\nSecure Future.',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            height: 1.1,
            color: AppColors.primaryText(context),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Join over 2 million users moving money with AI-powered fraud protection.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryText(context),
            height: 1.6,
          ),
        ),
      ],
    );
  }


  Widget _buildFeatureGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FeatureItem(icon: Icons.bolt_rounded, label: 'Instant'),
        _FeatureItem(icon: Icons.auto_graph_rounded, label: 'AI Secure'),
        _FeatureItem(icon: Icons.headset_mic_rounded, label: '24/7 Live'),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 62,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('Sign In to Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 62,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FeatureCarousel()));
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.secondarySurface(context), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(
              'Get Started',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryText(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.successGreen.withOpacity(0.15),
            radius: 18,
            child: Icon(Icons.shield_rounded, color: AppColors.successGreen, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Bank-grade AES 256-bit encryption.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
          ),
          Icon(Icons.info_outline_rounded, color: AppColors.successGreen.withOpacity(0.5), size: 16),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondarySurface(context)),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryText(context),
          ),
        ),
      ],
    );
  }
}