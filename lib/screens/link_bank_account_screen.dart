import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'final_step_screen.dart';

class LinkBankAccountScreen extends StatelessWidget {
  const LinkBankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryText),
        title: const Text(
          'Link Bank Account',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stepIndicator(),
              const SizedBox(height: 32),

              const Text(
                'Select your primary bank',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Link your account to enable secure UPI payments.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Bank Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: AppColors.primaryText),
                decoration: InputDecoration(
                  hintText: 'Search for your bank...',
                  hintStyle: const TextStyle(color: AppColors.mutedText),
                  prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'POPULAR BANKS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 20),
              _popularBanksGrid(),

              const SizedBox(height: 40),

              _generatedUpiIdCard(),

              const SizedBox(height: 100), // Extra space so content scrolls above bottom bar
            ],
          ),
        ),
      ),
      // Persistent bottom bar with Verify & Continue button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          border: Border(
            top: BorderSide(color: AppColors.secondarySurface, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: AppColors.subtleBlueGlow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FinalStepScreen(),
                  ),
                );
              },
              child: const Text(
                'Verify & Continue →',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Step 3 of 5',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '60% Completed',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.6,
            minHeight: 10,
            backgroundColor: AppColors.secondarySurface,
            valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _popularBanksGrid() {
    final banks = [
      {'name': 'HDFC', 'color': const Color(0xFFE91E63)},
      {'name': 'SBI', 'color': const Color(0xFF00BCD4)},
      {'name': 'ICICI', 'color': const Color(0xFFFF9800)},
      {'name': 'AXIS', 'color': const Color(0xFF9C27B0)},
      {'name': 'KOTAK', 'color': const Color(0xFF1976D2)},
      {'name': 'PNB', 'color': const Color(0xFF4CAF50)},
      {'name': 'All Banks', 'color': AppColors.mutedText.withOpacity(0.3)},
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 24,
      alignment: WrapAlignment.start,
      children: banks.map((bank) {
        final bool isAllBanks = bank['name'] == 'All Banks';
        return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAllBanks ? null : bank['color'] as Color,
                border: isAllBanks
                    ? Border.all(color: AppColors.mutedText.withOpacity(0.3), width: 2)
                    : null,
              ),
              child: isAllBanks
                  ? Icon(Icons.apps, color: AppColors.mutedText, size: 28)
                  : Center(
                child: Text(
                  (bank['name'] as String)[0],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              bank['name'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _generatedUpiIdCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR GENERATED UPI ID',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.6,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Edit ID',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'john.doe@icici',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                      children: const [
                        TextSpan(text: 'Linked to '),
                        TextSpan(
                          text: '+1234 **** *89',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: '. You can use this ID to receive money securely from any payment app.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.mutedText, size: 18),
              const SizedBox(width: 8),
              Text(
                'Bank grade security & encryption',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}