import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heisenbug/screens/feature_carousel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heisenbug',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,

        // googleSansTextTheme()
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: const TextStyle(color: Colors.white),
          displayMedium: const TextStyle(color: Colors.white),
          displaySmall: const TextStyle(color: Colors.white),
          headlineMedium: const TextStyle(color: Colors.white),
          headlineSmall: const TextStyle(color: Colors.white),
          titleLarge: const TextStyle(color: Colors.white),
          bodyLarge: const TextStyle(color: Color(0xFFB3B3B3)),
          bodyMedium: const TextStyle(color: Color(0xFFB3B3B3)),
        ),

        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFF2563EB),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF1D4ED8),
          surface: Color(0xFF0D0D0D),
          background: Color(0xFF000000),
          error: Color(0xFFEF4444),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFB3B3B3),
          onBackground: Colors.white,
          onError: Colors.black,
        ),
      ),
      home: const FeatureCarousel(),
    );
  }
}
