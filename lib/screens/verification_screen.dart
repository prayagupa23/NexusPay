import 'package:flutter/material.dart';
import 'package:heisenbug/screens/link_bank_account_screen.dart';
import '../theme/app_colors.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _hideAadhar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Verification',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20 , 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Step 2 of 5',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '40% Completed',
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.4,
                  minHeight: 10,
                  backgroundColor: AppColors.secondarySurface,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                ),
              ),

              const SizedBox(height: 28),

              // TITLE
              const Text(
                'Verify your identity',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Please enter your details to unlock full banking features. '
                    'Your data is encrypted and secure.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.secondaryText,
                ),
              ),

              const SizedBox(height: 28),

              // AADHAR
              const _Label('Aadhaar Number (12 digits)'),
              TextField(
                obscureText: _hideAadhar,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.primaryText),
                decoration: InputDecoration(
                  hintText: 'XXXX XXXX 1234',
                  hintStyle: const TextStyle(color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hideAadhar
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.mutedText,
                    ),
                    onPressed: () {
                      setState(() => _hideAadhar = !_hideAadhar);
                    },
                  ),
                  enabledBorder: _border(),
                  focusedBorder: _focusedBorder(),
                ),
              ),

              const SizedBox(height: 28),

              // BANK ACCOUNT
              const _Label('Bank Account Number'),
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.primaryText),
                decoration: InputDecoration(
                  hintText: 'Enter account number',
                  hintStyle: const TextStyle(color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  suffixIcon: const Icon(
                    Icons.account_balance,
                    color: AppColors.mutedText,
                  ),
                  enabledBorder: _border(),
                  focusedBorder: _focusedBorder(),
                ),
              ),

              const SizedBox(height: 28),

              // CONFIRM ACCOUNT
              const _Label('Re-enter Account Number'),
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.primaryText),
                decoration: InputDecoration(
                  hintText: 'Confirm account number',
                  hintStyle: const TextStyle(color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  suffixIcon: const Icon(
                    Icons.check_circle,
                    color: AppColors.successGreen,
                  ),
                  enabledBorder: _border(),
                  focusedBorder: _focusedBorder(),
                ),
              ),

              const SizedBox(height: 28),

              // SECURITY INFO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock, color: AppColors.successGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bank-grade 256-bit encryption. Your details are never shared.',
                        style: TextStyle(
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // VERIFY BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LinkBankAccountScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.subtleBlueGlow,
                  ),
                  child: const Text(
                    'Verify & Proceed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // WHY INFO
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.help_outline,
                    color: AppColors.primaryBlue,
                  ),
                  label: const Text(
                    'Why do we need this?',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
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

  OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.secondarySurface),
  );

  OutlineInputBorder _focusedBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(
      color: AppColors.primaryBlue,
      width: 1.5,
    ),
  );
}

// =========================
// LABEL
// =========================

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}
