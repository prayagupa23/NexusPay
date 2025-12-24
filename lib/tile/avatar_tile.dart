import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ContactAvatar extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const ContactAvatar({
    super.key,
    required this.name,
    this.onTap,
  });

// C O L O R S  O F  A V A T A R
  static const List<Color> avatarColors = [
    Color(0xFF1E88E5), // GPay Blue
    Color(0xFF43A047), // GPay Green
    Color(0xFFF4511E), // GPay Orange
    Color(0xFF8E24AA), // GPay Purple
    Color(0xFF3949AB), // Indigo Blue
    Color(0xFF00897B), // Teal Green
    Color(0xFFD81B60), // Pink Red
    Color(0xFF5E35B1), // Deep Violet
    Color(0xFF039BE5), // Light Blue
    Color(0xFF7CB342), // Soft Green
    Color(0xFFFDD835), // Yellow Accent
    Color(0xFF546E7A), // Neutral Blue Grey
    Color(0xFFEF6C00), // Amber Orange
    Color(0xFF6D4C41), // Brown Accent
    Color(0xFF26A69A), // Mint Teal
  ];

  Color _getAvatarColor() {
    // Use name's hash for consistent color per contact
    final int hash = name.toLowerCase().hashCode;
    return avatarColors[hash.abs() % avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _getAvatarColor();

    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: bgColor,
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White letter like Google Pay
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              name.split(" ").first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}