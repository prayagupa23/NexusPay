import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../theme/app_colors.dart';
import 'verification_screen.dart';
import '../services/user_registration_state.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  Country _selectedCountry = Country.parse('IN'); // Default to India for 10-digit phone
  bool _isLoading = false;
  String? _errorMessage;
  
  final _registrationState = UserRegistrationState();
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    
    // Load existing data if available
    if (_registrationState.fullName != null) {
      _nameController.text = _registrationState.fullName!;
    }
    if (_registrationState.phoneNumber != null) {
      _phoneController.text = _registrationState.phoneNumber!;
    }
    if (_registrationState.email != null) {
      _emailController.text = _registrationState.email!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dangerRed),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.dangerRed, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.dangerRed, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // FULL NAME
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Legal Full Name'),
                    _InputField(
                      controller: _nameController,
                      hint: 'e.g. Parth Salunke',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
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
                              favorite: const ['IN', 'US'],
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
                        Expanded(
                          child: _InputField(
                            controller: _phoneController,
                            hint: '8169312345',
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (!UserModel.isValidPhone(value.trim())) {
                                return 'Phone must be exactly 10 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // EMAIL
                    const _Label('Email Address'),
                    _InputField(
                      controller: _emailController,
                      hint: 'parth@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!UserModel.isValidEmail(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
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
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.subtleBlueGlow,
                    disabledBackgroundColor: AppColors.secondarySurface,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
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

  Future<void> _handleContinue() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // Check for duplicates
      final phoneExists = await _supabaseService.checkPhoneExists(phone);
      if (phoneExists) {
        setState(() {
          _errorMessage = 'This phone number is already registered';
          _isLoading = false;
        });
        return;
      }

      final emailExists = await _supabaseService.checkEmailExists(email);
      if (emailExists) {
        setState(() {
          _errorMessage = 'This email is already registered';
          _isLoading = false;
        });
        return;
      }

      // Save to registration state
      _registrationState.fullName = name;
      _registrationState.phoneNumber = phone;
      _registrationState.email = email;

      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const VerificationScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
  final TextEditingController? controller;
  final String hint;
  final TextInputType keyboardType;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _InputField({
    this.controller,
    required this.hint,
    required this.keyboardType,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(color: AppColors.primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.mutedText),
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        counterText: '',
        errorStyle: const TextStyle(color: AppColors.dangerRed, fontSize: 12),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.dangerRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.dangerRed,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
