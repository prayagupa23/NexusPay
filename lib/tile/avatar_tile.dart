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
    Color(0xFFE57373), // Deep Red
    Color(0xFF4DB6AC), // Deep Teal
    Color(0xFFFFB74D), // Deep Orange-Yellow
    Color(0xFF81C784), // Deep Mint Green
    Color(0xFFBA68C8), // Deep Purple
    Color(0xFFFF8A65), // Deep Coral
    Color(0xFF4FC3F7), // Deep Light Blue
    Color(0xFF9575CD), // Deep Lavender
    Color(0xFF64B5F6), // Deep Sky Blue
    Color(0xFFAED581), // Deep Light Green
    Color(0xFF78909C), // Deep Blue-Grey
    Color(0xFFFFAB91), // Deep Peach
    Color(0xFF90A4AE), // Deep Steel Blue
    Color(0xFFB39DDB), // Deep Lilac
    Color(0xFFFFCC80), // Deep Warm Yellow
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