import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:no_screenshot/no_screenshot.dart';
import 'package:heisenbug/screens/splash_screen.dart';
import 'package:heisenbug/utils/supabase_config.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await _enableScreenshotProtection();

  await SupabaseConfig.initialize();

  runApp(const MyApp());
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexusPay',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: const Color(0xFF0F172A), // Darker text for better contrast
          displayColor: const Color(0xFF0F172A),
        ),
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.lightBg,
        cardColor: AppColors.lightSurface,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSecondarySurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputBorder(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.focusColor(context), width: 2),
          ),
          labelStyle: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: AppColors.mutedText(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: Colors.white, // Pure white for maximum contrast
          displayColor: Colors.white,
        ),
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.darkBg,
        cardColor: AppColors.darkSurface,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSecondarySurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.inputBorder(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.focusColor(context), width: 2),
          ),
          labelStyle: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: AppColors.mutedText(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}