import 'package:flutter/material.dart';

class AppColors {
  // Shared (same in light & dark)
  // A professional Cobalt Blue - cleaner and more "Banking" than Indigo
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueHover = Color(0xFF1D4ED8);
  static const Color subtleBlueGlow = Color.fromRGBO(37, 99, 235, 0.12);

  // Danger / Error colors (shared)
  static const Color dangerRed = Color(0xFFE11D48);
  static const Color dangerBgDark = Color(0xFF4C0519);
  static const Color dangerBgLight = Color(0xFFFFF1F2);

  // Dark mode - "Midnight Slate"
  // Deep charcoal with a hint of blue-gray for a premium look
  static const Color darkBg = Color(0xFF020617);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkSecondarySurface = Color(0xFF1E293B);
  static const Color darkPrimaryText = Color(0xFFF8FAFC);
  static const Color darkSecondaryText = Color(0xFF94A3B8);
  static const Color darkMutedText = Color(0xFF475569);

  // Light mode - "Iceberg White"
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightSecondarySurface = Color(0xFFF1F5F9);
  static const Color lightPrimaryText = Color(0xFF0F172A);
  static const Color lightSecondaryText = Color(0xFF475569);
  static const Color lightMutedText = Color(0xFF94A3B8);

  // Status
  static const Color successGreen = Color(0xFF10B981);
  static const Color successBgDark = Color(0xFF064E3B);
  static const Color successBgLight = Color(0xFFECFDF5);

  // Warning colors
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color warningBgDark = Color(0xFF451A03);
  static const Color warningBgLight = Color(0xFFFFFBEB);

  // Info colors
  static const Color infoCyan = Color(0xFF0EA5E9);
  static const Color infoBgDark = Color(0xFF0C4A6E);
  static const Color infoBgLight = Color(0xFFF0F9FF);

  // Accent colors
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPink = Color(0xFFF472B6);

  // Mode-aware getters
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBg : lightBg;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color secondarySurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSecondarySurface : lightSecondarySurface;

  static Color primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPrimaryText : lightPrimaryText;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSecondaryText : lightSecondaryText;

  static Color mutedText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkMutedText : lightMutedText;

  static Color successBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? successBgDark : successBgLight;

  static Color dangerBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dangerBgDark : dangerBgLight;

  static Color warningBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? warningBgDark : warningBgLight;

  static Color infoBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? infoBgDark : infoBgLight;

  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSecondarySurface.withOpacity(0.5)
          : lightSecondarySurface.withOpacity(0.5);

  static Color shadowColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.6)
          : const Color(0xFF0F172A).withOpacity(0.06);

  static Color dividerColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSecondarySurface.withOpacity(0.3)
          : lightSecondarySurface.withOpacity(0.4);

  static Color disabledColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkMutedText.withOpacity(0.4)
          : lightMutedText.withOpacity(0.4);

  static Color focusColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? primaryBlue.withOpacity(0.2)
          : primaryBlue.withOpacity(0.12);

  static Color hoverColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.04)
          : Colors.black.withOpacity(0.02);

  static Color selectedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? primaryBlue.withOpacity(0.22)
          : primaryBlue.withOpacity(0.14);
}