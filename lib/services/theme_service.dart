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

class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const String _themePrefKey = 'is_dark_mode';
  ThemeMode _themeMode = ThemeMode.light;

  /// ValueNotifier for screens that only want to rebuild on theme changes
  /// (e.g. via [ValueListenableBuilder]).
  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppThemeColors get colors => AppThemeColors(isDarkMode);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themePrefKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    themeModeNotifier.value = _themeMode;
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    themeModeNotifier.value = _themeMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, isDark);
  }

  Future<void> toggleTheme([bool? isDark]) async {
    await setDarkMode(isDark ?? !isDarkMode);
  }
}