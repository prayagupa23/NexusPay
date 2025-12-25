import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'auth_choice_screen.dart';

class PinLockScreen extends StatefulWidget {
  final String phoneNumber;

  const PinLockScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _obscurePin = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _attempts = 0;
  static const int _maxAttempts = 5;

  late final SupabaseService _supabaseService;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(SupabaseConfig.client);
    _loadUser();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _supabaseService.getUserByPhone(widget.phoneNumber);
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      // If user not found, redirect to login
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
          (_) => false,
        );
      }
    }
  }

  Future<void> _verifyPin() async {
    if (_user == null) return;

    final enteredPin = _pinController.text.trim();

    if (enteredPin.length != 4) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    if (enteredPin == _user!.pin) {
      // PIN is correct - navigate to home
      if (mounted) {
        setState(() {
          _attempts = 0;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } else {
      // PIN is incorrect
      _attempts++;
      _isLoading = false;
      _pinController.clear();
      
      if (_attempts >= _maxAttempts) {
        setState(() {
          _errorMessage = 'Too many failed attempts. Please login again.';
        });
        // Clear stored login and redirect to auth choice
        await _clearLoginState();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
              (_) => false,
            );
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Incorrect PIN. ${_maxAttempts - _attempts} attempts remaining.';
        });
      }
    }
  }

  Future<void> _clearLoginState() async {
    // Clear stored phone number
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_phone');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBlue,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 50,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                'Enter PIN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your 4-digit PIN to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 40),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
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
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

              // PIN Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final hasDigit = index < _pinController.text.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: hasDigit
                          ? AppColors.primaryText
                          : AppColors.secondarySurface,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 60),

              // Numpad
              _buildNumpad(),

              const SizedBox(height: 40),

              // Use different account
              TextButton(
                onPressed: () async {
                  await _clearLoginState();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
                      (_) => false,
                    );
                  }
                },
                child: const Text(
                  'Use different account',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: List.generate(12, (index) {
        String value;
        if (index < 9) {
          value = (index + 1).toString();
        } else if (index == 9) {
          value = 'backspace';
        } else if (index == 10) {
          value = '0';
        } else {
          value = 'submit';
        }

        return InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () => _onKeyPress(value),
          child: Center(
            child: value == 'backspace'
                ? const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.primaryText,
                    size: 28,
                  )
                : value == 'submit'
                    ? Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _pinController.text.length == 4
                              ? AppColors.primaryBlue
                              : AppColors.secondarySurface,
                          shape: BoxShape.circle,
                          boxShadow: _pinController.text.length == 4
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
          ),
        );
      }),
    );
  }

  void _onKeyPress(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_pinController.text.isNotEmpty) {
          _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
        }
      } else if (value == 'submit') {
        if (_pinController.text.length == 4) {
          _verifyPin();
        }
      } else if (_pinController.text.length < 4) {
        _pinController.text += value;
        // Auto-submit when 4 digits are entered
        if (_pinController.text.length == 4) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _verifyPin();
          });
        }
      }
    });
  }
}

