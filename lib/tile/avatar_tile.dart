import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ContactAvatar extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const ContactAvatar({super.key, required this.name, this.onTap});

  static Color getAvatarBgColor(String name) {
    final int hash = name.hashCode;
    final List<Color> colors = [
      const Color(0xFFE8F0FF), // Soft Blue (JD Style)
      const Color(0xFFF5E1FF), // Soft Purple (MK Style)
      const Color(0xFFE0E7FF), // Indigo
      const Color(0xFFF3E8FF), // Lavender
    ];
    return colors[hash.abs() % colors.length];
  }

  static Color getAvatarTextColor(Color bg) {
    if (bg == const Color(0xFFE8F0FF) || bg == const Color(0xFFE0E7FF)) {
      return const Color(0xFF1A56DB); // Vibrant Deep Blue
    }
    return const Color(0xFF9333EA); // Vibrant Purple
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
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
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