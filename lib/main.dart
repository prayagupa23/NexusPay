// M A I N 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heisenbug/screens/feature_carousel.dart';

void main() {
  runApp(const MyApp());

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heisenbug',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFF2563EB),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFFFFFFFF)),
          displayMedium: TextStyle(color: Color(0xFFFFFFFF)),
          displaySmall: TextStyle(color: Color(0xFFFFFFFF)),
          headlineMedium: TextStyle(color: Color(0xFFFFFFFF)),
          headlineSmall: TextStyle(color: Color(0xFFFFFFFF)),
          titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
          bodyLarge: TextStyle(color: Color(0xFFB3B3B3)),
          bodyMedium: TextStyle(color: Color(0xFFB3B3B3)),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF1D4ED8),
          surface: Color(0xFF0D0D0D),
          background: Color(0xFF000000),
          error: Color(0xFFEF4444),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFFB3B3B3),
          onBackground: Color(0xFFFFFFFF),
          onError: Color(0xFF000000),
        ),
      ),
      home: const FeatureCarousel(),
    );
  }
}
