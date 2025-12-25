import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptics
import 'package:heisenbug/screens/link_bank_account_screen.dart';
import '../theme/app_colors.dart';
import '../services/user_registration_state.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  final _accountController = TextEditingController();
  final _confirmAccountController = TextEditingController();

  bool _hideAadhaar = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _registrationState = UserRegistrationState();
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildHeroSection(context),
                    const SizedBox(height: 32),

                    if (_errorMessage != null) _buildErrorCard(),

                    _buildVerificationForm(context),
                    const SizedBox(height: 32),

                    _buildSecurityNotice(context),
                    const SizedBox(height: 40),

                    _buildContinueButton(context),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primaryText(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Identity & Banking',
        style: TextStyle(color: AppColors.primaryText(context), fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STEP 2 OF 5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryBlue, letterSpacing: 1.2)),
              Text('40% Complete', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText(context))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.4,
              minHeight: 6,
              backgroundColor: AppColors.secondarySurface(context),
              valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primaryText(context), letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text(
          'We use industry-standard encryption to verify your details with regulatory authorities.',
          style: TextStyle(fontSize: 15, color: AppColors.secondaryText(context), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildVerificationForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('AADHAAR NUMBER'),
          _CustomTextField(
            controller: _aadhaarController,
            hint: '0000 0000 0000',
            maxLength: 12,
            obscureText: _hideAadhaar,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.fingerprint_rounded,
            suffix: IconButton(
              icon: Icon(_hideAadhaar ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
              onPressed: () => setState(() => _hideAadhaar = !_hideAadhaar),
            ),
            validator: (v) => UserModel.isValidAadhaar(v ?? '') ? null : 'Invalid 12-digit Aadhaar',
          ),
          const SizedBox(height: 24),

          _buildFieldLabel('BANK ACCOUNT NUMBER'),
          _CustomTextField(
            controller: _accountController,
            hint: 'Account Number',
            maxLength: 16,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.account_balance_rounded,
            validator: (v) => UserModel.isValidAccountNumber(v ?? '') ? null : 'Enter valid account number',
          ),
          const SizedBox(height: 24),

          _buildFieldLabel('CONFIRM ACCOUNT NUMBER'),
          _CustomTextField(
            controller: _confirmAccountController,
            hint: 'Re-enter Account Number',
            maxLength: 16,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.verified_rounded,
            validator: (v) => v == _accountController.text.trim() ? null : 'Numbers do not match',
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryBlue.withOpacity(0.8), letterSpacing: 1),
      ),
    );
  }

  Widget _buildSecurityNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: AppColors.successGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your data is encrypted using AES-256 bank-grade protocols.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.successGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Verify & Proceed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: Colors.redAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerify() async {
    HapticFeedback.mediumImpact();
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (await _supabaseService.checkAadhaarExists(_aadhaarController.text.trim())) {
        throw 'Aadhaar already registered';
      }
      if (await _supabaseService.checkBankAccountExists(_accountController.text.trim())) {
        throw 'Bank account already linked';
      }

      _registrationState
        ..aadhaarNumber = _aadhaarController.text.trim()
        ..bankAccountNumber = _accountController.text.trim();

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkBankAccountScreen()));
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final int maxLength;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const _CustomTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.maxLength,
    required this.validator,
    this.obscureText = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
        counterText: "",
        prefixIcon: Icon(prefixIcon, color: AppColors.primaryBlue, size: 20),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.mutedText(context), fontWeight: FontWeight.w400),
        filled: true,
        fillColor: AppColors.surface(context),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.secondarySurface(context), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}
