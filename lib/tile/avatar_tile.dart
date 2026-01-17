import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ContactAvatar extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;
  final bool isTrustedContact;

  const ContactAvatar({
    super.key,
    required this.name,
    this.onTap,
    this.isTrustedContact = false,
  });

  static Color getAvatarBgColor(
    BuildContext context,
    String name, {
    bool isTrustedContact = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isTrustedContact && !isDark) {
      // Trusted contacts in bright mode: Use blue gradient theme
      return const Color(0xFF1A56DB); // Primary blue color
    } else if (isDark) {
      // Dark mode: Use a slightly lighter gray-blue that works well with dark theme
      return const Color(0xFF2E3A59); // Dark gray-blue color
    } else {
      // Light mode: Use a lighter, softer color that works well with light theme
      return const Color(0xFF6B7280); // Lighter gray for light mode
    }
  }

  static Color getAvatarTextColor(BuildContext context, Color bg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      // Dark mode: Use light text color that contrasts well with dark background
      return Colors.white.withOpacity(0.9);
    } else {
      // Light mode: Use slightly darker text for better contrast with lighter background
      return Colors.white.withOpacity(0.95);
    }
  }

  String get _initials {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = getAvatarBgColor(
      context,
      name,
      isTrustedContact: isTrustedContact,
    );
    final Color textColor = getAvatarTextColor(context, bgColor);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor.withOpacity(0.9),
                  bgColor.withBlue(bgColor.blue - 30).withOpacity(0.9),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.split(" ").first,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText(context),
            ),
          ),
        ],
      ),
    );
  }
}
