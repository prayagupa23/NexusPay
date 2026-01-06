import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ContactAvatar extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const ContactAvatar({super.key, required this.name, this.onTap});

  static Color getAvatarBgColor(String name) {
    // Use a consistent dark gray-blue color from the theme
    return const Color(0xFF2E3A59); // Dark gray-blue color
  }

  static Color getAvatarTextColor(Color bg) {
    // Use a light text color that contrasts well with the dark background
    return Colors.white.withOpacity(0.9);
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
    final Color bgColor = getAvatarBgColor(name);
    final Color textColor = getAvatarTextColor(bgColor);

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