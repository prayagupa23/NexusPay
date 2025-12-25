import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds - GPay-inspired dark mode (true black primary, elevated dark gray for cards/surfaces)
  static const Color primaryBg = Color(0xFF000000);         // Pure Black (main background)
  static const Color darkSurface = Color(0xFF121212);       // Elevated cards / panels (GPay-style dark gray)
  static const Color secondarySurface = Color(0xFF1E1E1E);   // Secondary elements / modals (slightly lighter gray)
  static const Color bgColor = Color(0xFF0061FF);
  // Text Colors
  static const Color primaryText = Color(0xFFFFFFFF);      // Headings / Main text (pure white)
  static const Color secondaryText = Color(0xFFB3B3B3);     // Descriptions / Subtext
  static const Color mutedText = Color(0xFF7A7A7A);         // Hints / Inactive
  static const Color disabledText = Color(0xFF555555);      // Disabled states

  // Primary Accent (Security / Trust) - GPay blue
  static const Color primaryBlue = Color(0xFF0061FF);       // Authentic Google Pay blue
  static const Color primaryBlueHover = Color(0xFF3367D6);  // Slightly darker on press/active
  static const Color subtleBlueGlow = Color.fromRGBO(66, 133, 244, 0.25); // Soft glow overlay

  // Status & Risk Colors
  // High Risk / Fraud
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFF2A0E0E);          // Dark red-tinted background

  // Medium Risk / Warning
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFF2A1F0E);         // Dark amber-tinted background

  // Safe / Verified
  static const Color successGreen = Color(0xFF22C55E);
  static const Color successBg = Color(0xFF0E2A17);         // Dark green-tinted background
}