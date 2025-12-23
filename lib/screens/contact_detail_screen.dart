import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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

    return Scaffold(
      backgroundColor: AppColors.primaryBg,

      // C U S T O M  A P P  B A R 
      body: Column(
        children: [
          // T O P  A P P  B A R
          Container(
            padding: EdgeInsets.fromLTRB(
              10,
              statusBarHeight + 24,
              10,
              18,
            ),
            color: AppColors.secondarySurface,
            child: Row(
              children: [
                const BackButton(color: AppColors.primaryText),

                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryBg,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        upiId,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.more_vert, color: AppColors.primaryText),
              ],
            ),
          ),

          // TRANSACTIONS AREA (EMPTY FOR NOW)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: const [],
            ),
          ),
        ],
      ),

      // B O T T O M  B A R
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Row(
            children: [
              // P A Y  B U T T O N
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.primaryBlue,
                    width: 1.4,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Pay",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              //  M E S S A G E  F I E L D
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          "Message…",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: AppColors.primaryBlue,
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
