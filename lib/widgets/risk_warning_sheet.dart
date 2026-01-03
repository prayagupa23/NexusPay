//risk_warning_sheet.dart
import 'package:flutter/material.dart';
import '../models/risk_result.dart';
import '../theme/app_colors.dart';

class RiskWarningSheet extends StatelessWidget {
  final RiskResult result;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  const RiskWarningSheet({
    super.key,
    required this.result,
    required this.onProceed,
    required this.onCancel,
  });

  Color _riskColor() {
    switch (result.riskLevel) {
      case RiskLevel.high:
        return AppColors.dangerRed;
      case RiskLevel.medium:
        return AppColors.warningYellow;
      case RiskLevel.low:
        return AppColors.successGreen;
    }
  }

  Color _riskBgColor(BuildContext context) {
    switch (result.riskLevel) {
      case RiskLevel.high:
        return AppColors.dangerBg(context);
      case RiskLevel.medium:
        return AppColors.warningBg(context);
      case RiskLevel.low:
        return AppColors.successBg(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 24,
                    ), // Space for close button alignment
                    Flexible(
                      child: Text(
                        "Let's make sure your payment is safe",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText(context),
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    GestureDetector(
                      onTap: onCancel,
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: AppColors.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Risk indicator and title
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _riskBgColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _riskColor().withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _riskColor(),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getRiskTitle(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _riskColor(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Risk Score: ${result.riskScore.toStringAsFixed(1)} | ${result.riskLevel.name.toUpperCase()}",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _getRiskDescription(),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText(context),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Warning points
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Here are a few things to watch out for:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._getWarningPoints().map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.mutedText(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                point,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondaryText(context),
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Learn more link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Learn how to spot scams",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.infoCyan,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: TextButton(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.borderColor(context),
                            ),
                          ),
                        ),
                        child: Text(
                          "Cancel Payment",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondaryText(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Continue button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onProceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _riskColor(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          result.riskLevel == RiskLevel.high
                              ? "Accept Risk and Continue"
                              : "Continue Payment",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRiskTitle() {
    switch (result.riskLevel) {
      case RiskLevel.high:
        return "This payment is risky and could be a scam";
      case RiskLevel.medium:
        return "This payment is risky and could be a scam";
      case RiskLevel.low:
        return "Let's make sure your payment is safe";
    }
  }

  String _getRiskDescription() {
    switch (result.riskLevel) {
      case RiskLevel.high:
        return "We believe this payment could be a scam, so we stepped in to protect your money.";
      case RiskLevel.medium:
        return "If you experience one or more of these things, proceed with caution:";
      case RiskLevel.low:
        return "Here are a few things to watch out for:";
    }
  }

  List<String> _getWarningPoints() {
    if (result.reasons.isNotEmpty) {
      return result.reasons;
    }

    // Default warning points based on risk level
    switch (result.riskLevel) {
      case RiskLevel.high:
        return [
          "Requests to act fast or pleas for sympathy",
          "Being pressured to pay using Friends and Family for a good or service",
          "Unverified claims to be a trusted organization",
          "Ads and social media posts with offers that are too good to be true",
        ];
      case RiskLevel.medium:
        return [
          "Requests to act fast or pleas for sympathy",
          "Being pressured to pay using Friends and Family for a good or service",
          "Unverified claims to be a trusted organization",
          "Ads and social media posts with offers that are too good to be true",
        ];
      case RiskLevel.low:
        return [
          "Being pressured to pay using Friends and Family for a good or service",
          "Requests to act fast or pleas for sympathy",
          "Ads and social media posts with offers that are too good to be true",
          "Unverified claims to be a trusted organization",
        ];
    }
  }
}
