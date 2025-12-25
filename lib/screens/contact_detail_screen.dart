import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart';

class ContactDetailScreen extends StatelessWidget {
  final String name;
  final String upiId;

  const ContactDetailScreen({
    super.key,
    required this.name,
    required this.upiId,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final Color avatarBg = ContactAvatar.getAvatarBgColor(name);
    final Color avatarText = ContactAvatar.getAvatarTextColor(avatarBg);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          // 1. Creative Background Element (Mesh Gradient Blob)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    avatarBg.withOpacity(0.15),
                    avatarBg.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // 2. Formal & Enhanced Compact Header
              Container(
                padding: EdgeInsets.fromLTRB(8, statusBarHeight + 4, 16, 12),
                decoration: BoxDecoration(
                  color: AppColors.surface(context).withOpacity(0.8),
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppColors.primaryText(context), size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        _buildHeroAvatar(avatarBg, avatarText),
                        const SizedBox(width: 12),
                        _buildNameSection(context),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Creative Body (Empty State with Depth)
              Expanded(
                child: _buildTransactionBody(avatarBg),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassBottomBar(context, avatarBg),
    );
  }

  Widget _buildHeroAvatar(Color bg, Color text) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg, bg.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        name[0].toUpperCase(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: text,
        ),
      ),
    );
  }

  Widget _buildNameSection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText(context),
              letterSpacing: -0.5,
            ),
          ),
          Text(
            upiId,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText(context).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.verified_user_rounded, color: Colors.blue.shade400, size: 18),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: AppColors.primaryText(context)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTransactionBody(Color themeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Depth Element
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColor.withOpacity(0.05),
                ),
              ),
              Icon(
                Icons.auto_awesome_motion_rounded,
                size: 48,
                color: themeColor.withOpacity(0.4),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Security Encrypted Chat",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: themeColor.withOpacity(0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "No transactions found yet.",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBottomBar(BuildContext context, Color themeColor) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          decoration: BoxDecoration(
            color: AppColors.surface(context).withOpacity(0.85),
            border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              // FIXED BLUE PAY BUTTON (Formal & Creative)
              Container(
                height: 52,
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A56DB), // Your Primary Blue
                      Color(0xFF003AB5), // Deep Royal Blue
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A56DB).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "PAY",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Message Field
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bg(context).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondarySurface(context),
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(color: AppColors.primaryText(context)),
                    decoration: InputDecoration(
                      hintText: "Send a message...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppColors.mutedText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      suffixIcon: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFF1A56DB),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}