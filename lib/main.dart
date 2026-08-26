import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'constants/app_colors.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await AuthService.instance.init();
  await ThemeService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'CareerMate AI',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F7),
            fontFamily: 'Be Vietnam Pro',
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: AppColors.primaryPurple,
              primary: AppColors.primaryPurple,
              secondary: AppColors.primaryPurple,
              tertiary: AppColors.accentOrange,
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121218),
            fontFamily: 'Be Vietnam Pro',
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF7C59D9),
              primary: const Color(0xFF7C59D9),
              secondary: const Color(0xFF7C59D9),
              tertiary: AppColors.accentOrange,
              surface: const Color(0xFF1E1E2A),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E2A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF1E1E2A),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C59D9),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}