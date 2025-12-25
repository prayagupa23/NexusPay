import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../theme/app_colors.dart';
import 'verification_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  Country _selectedCountry = Country.parse('US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock, size: 16, color: AppColors.primaryBlue),
                SizedBox(width: 6),
                Text(
                  'Secure',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), // ⬅ moved UI down
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STEP INFO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Step 1 of 5',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '20% Completed',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.2, // 1/5
                  minHeight: 10,
                  backgroundColor: AppColors.secondarySurface,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                ),
              ),

              const SizedBox(height: 36),

              // TITLE
              const Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Let’s get started with your account setup. '
                    'We need this info to verify your identity.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.secondaryText,
                ),
              ),

              const SizedBox(height: 32),

              // FULL NAME
              const _Label('Legal Full Name'),
              const _InputField(
                hint: 'e.g. Jane Doe',
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 28),

              // MOBILE NUMBER
              const _Label('Mobile Number'),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        favorite: const ['US', 'IN'],
                        countryListTheme: CountryListThemeData(
                          backgroundColor: AppColors.primaryBg,
                          textStyle: const TextStyle(
                            color: AppColors.primaryText,
                          ),
                          bottomSheetHeight: 520,
                          inputDecoration: const InputDecoration(
                            hintText: 'Search country',
                            hintStyle: TextStyle(color: AppColors.mutedText),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: AppColors.secondarySurface),
                            ),
                          ),
                        ),
                        onSelect: (country) {
                          setState(() => _selectedCountry = country);
                        },
                      );
                    },
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.secondarySurface,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedCountry.flagEmoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+${_selectedCountry.phoneCode}',
                            style: const TextStyle(
                              color: AppColors.primaryText,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.mutedText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _InputField(
                      hint: '(555) 000-0000',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // EMAIL
              const _Label('Email Address'),
              const _InputField(
                hint: 'jane@example.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 10),

              const Text(
                'We’ll send a verification link to this email.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
              ),

              const SizedBox(height: 30),

              // CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VerificationScreen(),
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
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // PRIVACY
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                      TextSpan(
                        text: 'Terms of Service.',
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// REUSABLE WIDGETS
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

class _InputField extends StatelessWidget {
  final String hint;
  final TextInputType keyboardType;

  const _InputField({
    required this.hint,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.mutedText),
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.secondarySurface,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
