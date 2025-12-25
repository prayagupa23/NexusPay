import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heisenbug/screens/splash_screen.dart';
import 'package:heisenbug/utils/supabase_config.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heisenbug',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Follows device setting
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