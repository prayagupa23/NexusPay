import 'package:flutter/material.dart';
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
  
  bool _hideAadhar = true;
  bool _isLoading = false;
  String? _errorMessage;
  
  final _registrationState = UserRegistrationState();
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    
    // Load existing data if available
    if (_registrationState.aadhaarNumber != null) {
      _aadhaarController.text = _registrationState.aadhaarNumber!;
    }
    if (_registrationState.bankAccountNumber != null) {
      _accountController.text = _registrationState.bankAccountNumber!;
      _confirmAccountController.text = _registrationState.bankAccountNumber!;
    }
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
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

              // AADHAR
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Aadhaar Number (12 digits)'),
                    TextFormField(
                      controller: _aadhaarController,
                      obscureText: _hideAadhar,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      style: const TextStyle(color: AppColors.primaryText),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter Aadhaar number';
                        }
                        if (!UserModel.isValidAadhaar(value.trim())) {
                          return 'Aadhaar must be exactly 12 digits';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '1234 5678 9012',
                        hintStyle: const TextStyle(color: AppColors.mutedText),
                        filled: true,
                        fillColor: AppColors.darkSurface,
                        counterText: '',
                        errorStyle: const TextStyle(color: AppColors.dangerRed, fontSize: 12),
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
                        errorBorder: _errorBorder(),
                        focusedErrorBorder: _errorBorder(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // BANK ACCOUNT
                    const _Label('Bank Account Number'),
                    TextFormField(
                      controller: _accountController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      style: const TextStyle(color: AppColors.primaryText),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter account number';
                        }
                        if (!UserModel.isValidAccountNumber(value.trim())) {
                          return 'Account number must be exactly 12 digits';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '123456789012',
                        hintStyle: const TextStyle(color: AppColors.mutedText),
                        filled: true,
                        fillColor: AppColors.darkSurface,
                        counterText: '',
                        errorStyle: const TextStyle(color: AppColors.dangerRed, fontSize: 12),
                        suffixIcon: const Icon(
                          Icons.account_balance,
                          color: AppColors.mutedText,
                        ),
                        enabledBorder: _border(),
                        focusedBorder: _focusedBorder(),
                        errorBorder: _errorBorder(),
                        focusedErrorBorder: _errorBorder(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // CONFIRM ACCOUNT
                    const _Label('Re-enter Account Number'),
                    TextFormField(
                      controller: _confirmAccountController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      style: const TextStyle(color: AppColors.primaryText),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please confirm account number';
                        }
                        if (value.trim() != _accountController.text.trim()) {
                          return 'Account numbers do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '123456789012',
                        hintStyle: const TextStyle(color: AppColors.mutedText),
                        filled: true,
                        fillColor: AppColors.darkSurface,
                        counterText: '',
                        errorStyle: const TextStyle(color: AppColors.dangerRed, fontSize: 12),
                        suffixIcon: const Icon(
                          Icons.check_circle,
                          color: AppColors.successGreen,
                        ),
                        enabledBorder: _border(),
                        focusedBorder: _focusedBorder(),
                        errorBorder: _errorBorder(),
                        focusedErrorBorder: _errorBorder(),
                      ),
                    ),
                  ],
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
                  onPressed: _isLoading ? null : _handleVerify,
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

  Future<void> _handleVerify() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final aadhaar = _aadhaarController.text.trim();
    final account = _accountController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // Check for duplicates
      final aadhaarExists = await _supabaseService.checkAadhaarExists(aadhaar);
      if (aadhaarExists) {
        setState(() {
          _errorMessage = 'This Aadhaar number is already registered';
          _isLoading = false;
        });
        return;
      }

      final accountExists = await _supabaseService.checkBankAccountExists(account);
      if (accountExists) {
        setState(() {
          _errorMessage = 'This bank account is already linked';
          _isLoading = false;
        });
        return;
      }

      // Save to registration state
      _registrationState.aadhaarNumber = aadhaar;
      _registrationState.bankAccountNumber = account;

      // Navigate to next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LinkBankAccountScreen(),
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

  OutlineInputBorder _errorBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(
      color: AppColors.dangerRed,
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
