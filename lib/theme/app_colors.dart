// lib/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color primaryBg = Color(0xFF000000);         // Pure Black
  static const Color darkSurface = Color(0xFF0D0D0D);       // Cards / Panels
  static const Color secondarySurface = Color(0xFF141414); // Modals / Sidebars

  // Text Colors
  static const Color primaryText = Color(0xFFFFFFFF);      // Headings
  static const Color secondaryText = Color(0xFFB3B3B3);     // Descriptions
  static const Color mutedText = Color(0xFF7A7A7A);         // Hint / Muted
  static const Color disabledText = Color(0xFF555555);      // Disabled

  // Primary Accent (Security / Trust)
  static const Color primaryBlue = Color(0xFF2563EB);       // Main Blue
  static const Color primaryBlueHover = Color(0xFF1D4ED8);  // Hover / Active
  static const Color subtleBlueGlow = Color.fromRGBO(37, 99, 235, 0.25); // Glow overlay

  // Status & Risk Colors
  // High Risk / Fraud
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFF2A0E0E);          // Dark Red BG

  // Medium Risk / Warning
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFF2A1F0E);         // Dark Amber BG

  // Safe / Verified
  static const Color successGreen = Color(0xFF22C55E);
  static const Color successBg = Color(0xFF0E2A17);         // Dark Green BG
}
