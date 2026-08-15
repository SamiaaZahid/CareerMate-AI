import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

/// Excelerate + CareerMate AI brand colors.
/// Purple is our primary UI color (matches existing screens).
/// Orange is Excelerate's official brand color, used as an accent
/// on the logo and key call-to-action moments.
class AppColors {
  static const Color primary = Color(0xFF54309C);
  static const Color primaryAccent = Color(0xFF6C4AB6);
  static const Color brandAccent = Color(0xFFFC603F); // Excelerate orange
  static const Color background = Color(0xFFF5F5F7);
  static const Color border = Color(0xFFE8E1F5);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareerMate AI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Be Vietnam Pro',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryAccent,
          tertiary: AppColors.brandAccent,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryAccent,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}