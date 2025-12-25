import 'package:flutter/material.dart';

class ContactAvatar extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const ContactAvatar({
    super.key,
    required this.name,
    this.onTap,
  });


  static const List<Color> avatarColors = [
    Color(0xFF0061FF)
  ];

  // Brightest cyan-blue for the character (vibrant & stands out beautifully)
  static const Color letterColor = Color(0xFFFFFFFF);

  Color? get bgColor => null;

  @override
  Widget build(BuildContext context) {
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final String firstName = name.split(" ").first;

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
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white, // White letter like Google Pay
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}