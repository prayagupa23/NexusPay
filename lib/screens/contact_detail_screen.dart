import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart';
import 'payment_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  final String name;
  final String upiId;

  const ContactDetailScreen({super.key, required this.name, required this.upiId});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Use the static helper from ContactAvatar to fix the error
    final Color avatarBg = ContactAvatar.getAvatarBgColor(name);
    final Color avatarText = ContactAvatar.getAvatarTextColor(avatarBg);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, statusBarHeight + 10, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              border: Border(bottom: BorderSide(color: AppColors.secondarySurface(context).withOpacity(0.5))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.primaryText(context)),
                  onPressed: () => Navigator.pop(context),
                ),
                // Updated to match the high-fidelity circular style
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarBg,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: avatarText),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primaryText(context))),
                      Text(upiId, style: TextStyle(fontSize: 13, color: AppColors.secondaryText(context))),
                    ],
                  ),
                ),
                IconButton(icon: Icon(Icons.more_vert, color: AppColors.primaryText(context)), onPressed: () {}),
              ],
            ),
          ),
          // Transaction Body... (remaining code is same as yours)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 64, color: AppColors.mutedText(context).withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text("No transactions yet", style: TextStyle(fontSize: 16, color: AppColors.secondaryText(context))),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomPayBar(context),
    );
  }

  Widget _buildBottomPayBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {}, // Navigate to Payment
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(100, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text("Pay", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.secondarySurface(context).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Send a message...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.mutedText(context), fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}