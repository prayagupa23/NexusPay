import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Haptic feedback
import 'package:country_picker/country_picker.dart';
import 'package:no_screenshot/no_screenshot.dart';
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

  Country _selectedCountry = Country.parse('IN');
  bool _isLoading = false;
  String? _errorMessage;

  final _registrationState = UserRegistrationState();
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _enableScreenshotProtection();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _nameController.text = _registrationState.fullName ?? '';
    _phoneController.text = _registrationState.phoneNumber ?? '';
    _emailController.text = _registrationState.email ?? '';
  }

  @override
  void dispose() {
    _disableScreenshotProtection();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enableScreenshotProtection() async {
    try {
      await NoScreenshot.instance.screenshotOff();
    } catch (e) {
      debugPrint('Error enabling screenshot protection: $e');
    }
  }

  Future<void> _disableScreenshotProtection() async {
    try {
      await NoScreenshot.instance.screenshotOn();
    } catch (e) {
      debugPrint('Error disabling screenshot protection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    if (_errorMessage != null) _buildErrorBanner(),
                    _buildForm(context),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                    const SizedBox(height: 32),
                    _buildFooter(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.bg(context),
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondarySurface(context), width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 14),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 14, color: AppColors.successGreen),
              const SizedBox(width: 6),
              Text(
                'SECURE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP 1 OF 5',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                '20% Complete',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mutedText(context)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.2,
              minHeight: 6,
              backgroundColor: AppColors.secondarySurface(context),
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Details',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.primaryText(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please ensure these details match your official identity documents for a smooth verification.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.secondaryText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('FULL NAME'),
          _InputField(
            controller: _nameController,
            hint: 'e.g. John Doe',
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) => v == null || v.trim().length < 3 ? 'Please enter your legal name' : null,
          ),
          const SizedBox(height: 24),
          const _Label('MOBILE NUMBER'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    favorite: const ['IN'],
                    countryListTheme: CountryListThemeData(
                      borderRadius: BorderRadius.circular(24),
                      inputDecoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search country',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    onSelect: (c) => setState(() => _selectedCountry = c),
                  );
                },
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondarySurface(context), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedCountry.flagEmoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '+${_selectedCountry.phoneCode}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText(context),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.mutedText(context), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  controller: _phoneController,
                  hint: '00000 00000',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (v) => UserModel.isValidPhone(v ?? '') ? null : 'Invalid phone number',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _Label('EMAIL ADDRESS'),
          _InputField(
            controller: _emailController,
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.alternate_email_rounded,
            validator: (v) => UserModel.isValidEmail(v ?? '') ? null : 'Enter a valid email address',
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
          height: 24, width: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC1C1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: Color(0xFFD32F2F), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Securing your data is our top priority.',
            style: TextStyle(fontSize: 12, color: AppColors.mutedText(context)),
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: AppColors.mutedText(context), height: 1.5),
              children: [
                const TextSpan(text: 'By continuing, you agree to our '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Terms',
                  style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    HapticFeedback.lightImpact();
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (await _supabaseService.checkPhoneExists(_phoneController.text.trim())) {
        setState(() => _errorMessage = 'This phone number is already registered.');
        return;
      }
      if (await _supabaseService.checkEmailExists(_emailController.text.trim())) {
        setState(() => _errorMessage = 'This email address is already registered.');
        return;
      }

      _registrationState
        ..fullName = _nameController.text.trim()
        ..phoneNumber = _phoneController.text.trim()
        ..email = _emailController.text.trim();

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationScreen()));
      }
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w800,
          color: AppColors.secondaryText(context).withOpacity(0.8),
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
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    this.controller,
    required this.hint,
    required this.keyboardType,
    this.maxLength,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.mutedText(context), fontWeight: FontWeight.normal),
        filled: true,
        fillColor: AppColors.surface(context),
        counterText: '',
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: AppColors.mutedText(context)) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.secondarySurface(context), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}