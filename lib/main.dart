import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/api_keys.dart';
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

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await AuthService.instance.init();
  await ThemeService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'CareerMate AI',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeService.instance.themeMode,

          // LIGHT THEME
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F7),
            cardColor: Colors.white,
            fontFamily: 'Be Vietnam Pro',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryPurple,
              brightness: Brightness.light,
              primary: AppColors.primaryPurple,
              secondary: AppColors.primaryPurple,
              tertiary: AppColors.accentOrange,
              surface: Colors.white,
              onSurface: const Color(0xFF1F1F28),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme:
                const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primaryPurple,
              unselectedItemColor: Color(0xFF8B8B98),
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

          // DARK THEME
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121216),
            cardColor: const Color(0xFF1E1E26),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E1E26),
            ),
            fontFamily: 'Be Vietnam Pro',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryPurple,
              brightness: Brightness.dark,
              primary: const Color(0xFFA582F7),
              secondary: const Color(0xFFA582F7),
              tertiary: AppColors.accentOrange,
              surface: const Color(0xFF1E1E26),
              onSurface: const Color(0xFFF4F4F8),
              onSurfaceVariant: const Color(0xFFA0A0B2),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E26),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme:
                const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E26),
              selectedItemColor: Color(0xFFA582F7),
              unselectedItemColor: Color(0xFF8B8B98),
            ),
            dividerTheme: const DividerThemeData(
              color: Color(0xFF2C2C3A),
              thickness: 1,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA582F7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFA582F7),
              ),
            ),
          ),

          home: const LoginScreen(),
        );
      },
    );
  }
}