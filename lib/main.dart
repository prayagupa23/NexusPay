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
        textTheme: GoogleFonts.interTextTheme(),
        primaryColor: AppColors.primaryBlue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.interTextTheme(),
        primaryColor: AppColors.primaryBlue,
      ),
      home: const SplashScreen(),
    );
  }
}