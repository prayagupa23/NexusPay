import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'auth_choice_screen.dart';
import '../services/supabase_service.dart';
import '../utils/supabase_config.dart';
import '../models/user_model.dart';
import 'package:heisenbug/core/user_session.dart';

class PinLockScreen extends StatefulWidget {
  final String phoneNumber;

  const PinLockScreen({super.key, required this.phoneNumber});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();

  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isLoading = false;
  bool _biometricAvailable = false;
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
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (mounted) {
        setState(() {
          _biometricAvailable = canCheck || isSupported;
        });
      }
    } catch (_) {
      _biometricAvailable = false;
    }
  }

  Future<void> _authenticateWithFingerprint() async {
    if (_isLoading || !_biometricAvailable) return;

    try {
      final success = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (success && mounted) {
        HapticFeedback.heavyImpact();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (_) {}
  }

  Future<void> _loadUser() async {
    try {
      final user = await _supabaseService.getUserByPhone(widget.phoneNumber);
      if (user == null || user.userId == null) {
        throw Exception('Invalid user session');
      }
      UserSession.userId = user.userId;
      if (mounted) setState(() => _user = user);
    } catch (_) {
      _navigateToAuth();
    }
  }

  void _navigateToAuth() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
      (_) => false,
    );
  }

  Future<void> _verifyPin() async {
    if (_user == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(500.ms);

    if (_pinController.text == _user!.pin) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } else {
      _handleFailure();
    }
  }

  void _handleFailure() {
    HapticFeedback.vibrate();
    setState(() {
      _attempts++;
      _isLoading = false;
      _pinController.clear();
      _errorMessage = _attempts >= _maxAttempts
          ? 'Security Lockout Initiated'
          : 'Incorrect PIN. ${_maxAttempts - _attempts} attempts left';
    });

    if (_attempts >= _maxAttempts) {
      _clearAndExit();
    }
  }

  Future<void> _clearAndExit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_phone');
    await Future.delayed(2.seconds);
    _navigateToAuth();
  }

  void _onKeyPress(String value) {
    if (_isLoading) return;
    HapticFeedback.selectionClick();

    setState(() {
      if (value == 'backspace') {
        if (_pinController.text.isNotEmpty) {
          _pinController.text =
              _pinController.text.substring(0, _pinController.text.length - 1);
        }
      } else if (_pinController.text.length < 4) {
        _pinController.text += value;
        if (_pinController.text.length == 4) _verifyPin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildPinDots(),
                if (_errorMessage != null) _buildErrorLabel(),
                const Spacer(),
                _buildGlassNumpad(),
              ],
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 45,
            backgroundColor: AppColors.secondarySurface(context),
            child: Icon(Icons.person_rounded,
                size: 40, color: AppColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText(context),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _user?.fullName ?? "Secure User",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        bool active = i < _pinController.text.length;
        return AnimatedContainer(
          duration: 200.ms,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? AppColors.primaryBlue
                  : AppColors.mutedText(context).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.4),
                        blurRadius: 10)
                  ]
                : [],
          ),
        )
            .animate(target: active ? 1 : 0)
            .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2));
      }),
    )
        .animate(target: _errorMessage != null ? 1 : 0)
        .shake(hz: 6, offset: const Offset(4, 0));
  }

  Widget _buildErrorLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
            fontSize: 13),
      ),
    ).animate().fadeIn();
  }

  Widget _buildGlassNumpad() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          decoration: BoxDecoration(
            color: AppColors.surface(context).withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border.all(
                color: AppColors.mutedText(context).withOpacity(0.1)),
          ),
          child: Column(
            children: [
              if (_biometricAvailable)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: GestureDetector(
                    onTap: _authenticateWithFingerprint,
                    child: Column(
                      children: [
                        Icon(Icons.fingerprint,
                            size: 48, color: AppColors.primaryBlue),
                        const SizedBox(height: 8),
                        Text(
                          "Use Fingerprint",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText(context),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _numpadRow(['1', '2', '3']),
              _numpadRow(['4', '5', '6']),
              _numpadRow(['7', '8', '9']),
              _numpadRow([null, '0', 'backspace']),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.3, end: 0, duration: 500.ms);
  }

  Widget _numpadRow(List<String?> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: values.map((val) {
          if (val == null) return const SizedBox(width: 50);
          return _numpadKey(val);
        }).toList(),
      ),
    );
  }

  Widget _numpadKey(String val) {
    bool isIcon = val == 'backspace';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(val),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          child: isIcon
              ? Icon(Icons.backspace_outlined,
                  color: AppColors.primaryText(context), size: 20)
              : Text(val,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText(context))),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 3),
            const SizedBox(height: 20),
            Text(
              "SECURE ACCESS...",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 2),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}
