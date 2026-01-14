import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'auth_choice_screen.dart';
import 'pin_lock_screen.dart';
//import 'package:heisenbug/services/risk_engine_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    final loggedInPhone = prefs.getString('logged_in_phone');
    final hasCompletedSetup = prefs.getBool('setup_completed') ?? false;

    if (!mounted) return;

    if (loggedInPhone != null && loggedInPhone.isNotEmpty) {
      if (hasCompletedSetup) {
        // User is fully set up, go to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User is logged in but not fully set up, go to PIN screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PinLockScreen(phoneNumber: loggedInPhone)),
        );
      }
    } else {
      // User is not logged in, go to auth choice screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBlue, width: 4),
              ),
              child: Icon(Icons.account_balance_wallet_rounded, size: 72, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 32),
            Text(
              'Heisenbug',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryText(context)),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }
}
