import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeColors {
  final bool isDark;
  AppThemeColors(this.isDark);

  Color get scaffoldBackground => isDark ? const Color(0xFF121218) : const Color(0xFFF5F5F7);
  Color get surfaceCard => isDark ? const Color(0xFF1E1E2A) : Colors.white;
  Color get primaryText => isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1F1F28);
  Color get subtitleText => isDark ? const Color(0xFFA0A0B0) : const Color(0xFF8B8B98);
  Color get primaryPurple => isDark ? const Color(0xFF8D68F0) : const Color(0xFF54309C);
  Color get appBarBackground => isDark ? const Color(0xFF1E1E2A) : const Color(0xFF54309C);
  Color get chipBackground => isDark ? const Color(0xFF2B283E) : const Color(0xFFF2EDFC);
  Color get borderColor => isDark ? const Color(0xFF2E2C42) : const Color(0xFFE8E1F5);
  Color get dividerColor => isDark ? const Color(0xFF2D2A40) : const Color(0xFFF0ECF8);
  Color get bottomNavBg => isDark ? const Color(0xFF1E1E2A) : Colors.white;
  Color get inputFillColor => isDark ? const Color(0xFF181822) : Colors.white;
}

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;
  AppThemeColors get colors => AppThemeColors(isDarkMode);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme(bool isDark) async {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }
}
