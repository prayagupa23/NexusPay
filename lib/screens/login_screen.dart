import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'package:heisenbug/core/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  bool _obscurePin = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final pinBoxSize = screenWidth / 5.3;

    return Scaffold(
      resizeToAvoidBottomInset: false, // ⭐ CRITICAL FIX
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryText(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 28,
                right: 28,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        _buildHeader(context),
                        const SizedBox(height: 32),

                        if (_errorMessage != null) _buildErrorCard(),

                        _buildSectionLabel('PHONE NUMBER'),
                        _buildPhoneField(context),

                        const SizedBox(height: 28),

                        _buildPinHeader(context),
                        const SizedBox(height: 12),
                        _buildPinDisplay(context, pinBoxSize),

                        // ✅ Hidden PIN input with ZERO layout impact
                        Offstage(
                          offstage: true,
                          child: TextFormField(
                            controller: _pinController,
                            focusNode: _pinFocusNode,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            autofocus: true,
                            onChanged: (v) {
                              setState(() {});
                              if (v.length == 4) _handleLogin();
                            },
                            decoration: const InputDecoration(counterText: ''),
                          ),
                        ),

                        const SizedBox(height: 36),
                        _buildLoginButton(),
                        const SizedBox(height: 8),
                        _buildForgotPin(context),

                        const Spacer(),
                        const SizedBox(height: 24),
                        _buildSecurityFooter(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------- UI Builders ----------------

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: AppColors.primaryText(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Securely access your account',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.primaryBlue.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(
        color: AppColors.primaryText(context),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Enter 10-digit number',
        prefixIcon: Icon(
          Icons.phone_iphone_rounded,
          color: AppColors.primaryBlue,
        ),
        filled: true,
        fillColor: AppColors.surface(context),
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPinHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionLabel('4-DIGIT PIN'),
        IconButton(
          onPressed: () => setState(() => _obscurePin = !_obscurePin),
          icon: Icon(
            _obscurePin
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: AppColors.mutedText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPinDisplay(BuildContext context, double size) {
    return GestureDetector(
      onTap: () => _pinFocusNode.requestFocus(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          final isFilled = index < _pinController.text.length;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isFilled
                  ? AppColors.primaryBlue.withOpacity(0.05)
                  : AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isFilled
                    ? AppColors.primaryBlue
                    : AppColors.secondarySurface(context),
                width: isFilled ? 2 : 1.5,
              ),
            ),
            child: Center(
              child: Text(
                isFilled
                    ? (_obscurePin ? '●' : _pinController.text[index])
                    : '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText(context),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : const Text(
                'Sign In',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _buildForgotPin(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Text(
          'Trouble signing in?',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_person_rounded,
            color: AppColors.successGreen,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'End-to-end encrypted connection',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryText(context).withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Logic ----------------

Future<void> _handleLogin() async {
  HapticFeedback.mediumImpact();
  setState(() => _errorMessage = null);

  setState(() => _isLoading = true);
  try {
    final user = await _supabaseService.getUserByPhone(
      _phoneController.text.trim(),
    );

    if (user == null || user.pin != _pinController.text.trim()) {
      throw Exception();
    }

    // ✅ THIS IS THE CRITICAL LINE
    UserSession.userId = user.userId; // <-- store once

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'logged_in_phone',
      _phoneController.text.trim(),
    );

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  } catch (_) {
    setState(() {
      _errorMessage = 'The phone number or PIN is incorrect.';
      _isLoading = false;
      _pinController.clear();
    });
    HapticFeedback.vibrate();
  }
}

}
