import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../tile/avatar_tile.dart';
import 'payment_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  final String name;
  final String upiId;

  const ContactDetailScreen({
    super.key,
    required this.name,
    required this.upiId,
  });

  Color _getAvatarColor() {
    final int hash = name.toLowerCase().hashCode;
    return ContactAvatar.avatarColors[
    hash.abs() % ContactAvatar.avatarColors.length
    ];
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final avatarColor = _getAvatarColor();

    return Scaffold(
      backgroundColor: Colors.black,

      body: Column(
        children: [
          // 🔹 GPay-style App Bar
          Container(
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 16, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF121212),
              border: Border(
                bottom: BorderSide(color: Colors.white10),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(width: 8),

                // ✅ AVATAR ONLY (NO NAME BELOW)
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Name + UPI (right side)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        upiId,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 🔹 Empty transactions state
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No transactions yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔹 Bottom Pay Bar
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              // 🔵 PAY BUTTON (GPay-style)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PaymentScreen(name: name, upiId: upiId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Pay",
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 💬 MESSAGE BAR (GPay-style)
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Message",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.white54,
                              fontSize: 14.5,
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                          ),
                        ),
                      ),

                      // ➤ SEND BUTTON (circle like GPay)
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {},
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.send_rounded,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
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
