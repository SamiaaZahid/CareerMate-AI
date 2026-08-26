import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import 'feedback_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../analysis_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3;
  String? _name;
  String? _email;
  bool _loading = true;
  bool _notificationsEnabled = true;

  TextStyle _sectionStyle(AppThemeColors colors) => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colors.primaryText,
      );

  TextStyle _labelStyle(AppThemeColors colors) => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.subtitleText,
      );

  TextStyle _valueStyle(AppThemeColors colors) => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.primaryText,
      );

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final user = await AuthService.instance.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _name = (user?['name'] as String?)?.trim();
      _email = (user?['email'] as String?)?.trim();
      _loading = false;
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of CareerMate AI?',
          style: TextStyle(fontFamily: 'Be Vietnam Pro'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentOrange),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, themeMode, _) {
        final colors = ThemeService.instance.colors;
        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: colors.appBarBackground,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: ['sans-serif'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Account', style: _sectionStyle(colors)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.borderColor),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 14,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: colors.chipBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: colors.primaryPurple,
                                  ),
                                ),
                                title: Text(
                                  (_name == null || _name!.isEmpty) ? 'User Profile' : _name!,
                                  style: _valueStyle(colors),
                                ),
                                subtitle: Text(
                                  (_email == null || _email!.isEmpty) ? 'Not set' : _email!,
                                  style: _labelStyle(colors),
                                ),
                                trailing: Icon(Icons.chevron_right, color: colors.subtitleText),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(height: 1, indent: 16, endIndent: 16, color: colors.dividerColor),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: colors.chipBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.edit_note_rounded,
                                    color: colors.primaryPurple,
                                  ),
                                ),
                                title: Text('Edit Profile', style: _valueStyle(colors)),
                                trailing: Icon(Icons.chevron_right, color: colors.subtitleText),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Preferences & Support', style: _sectionStyle(colors)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.borderColor),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 14,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                secondary: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: colors.chipBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    ThemeService.instance.isDarkMode
                                        ? Icons.dark_mode_rounded
                                        : Icons.dark_mode_outlined,
                                    color: colors.primaryPurple,
                                  ),
                                ),
                                title: Text(
                                  'Dark Mode',
                                  style: _valueStyle(colors),
                                ),
                                subtitle: Text(
                                  ThemeService.instance.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                                  style: _labelStyle(colors),
                                ),
                                value: ThemeService.instance.isDarkMode,
                                activeThumbColor: colors.primaryPurple,
                                onChanged: (val) async {
                                  await ThemeService.instance.toggleTheme(val);
                                },
                              ),
                              Divider(height: 1, indent: 16, endIndent: 16, color: colors.dividerColor),
                              SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                secondary: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: colors.chipBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    color: colors.primaryPurple,
                                  ),
                                ),
                                title: Text(
                                  'Push Notifications',
                                  style: _valueStyle(colors),
                                ),
                                value: _notificationsEnabled,
                                activeThumbColor: colors.primaryPurple,
                                onChanged: (val) {
                                  setState(() {
                                    _notificationsEnabled = val;
                                  });
                                },
                              ),
                              Divider(height: 1, indent: 16, endIndent: 16, color: colors.dividerColor),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: colors.chipBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.feedback_outlined,
                                    color: colors.primaryPurple,
                                  ),
                                ),
                                title: Text(
                                  'Send Feedback',
                                  style: _valueStyle(colors),
                                ),
                                subtitle: Text(
                                  'Share your ideas, suggestions, or report an issue',
                                  style: _labelStyle(colors),
                                ),
                                trailing: Icon(Icons.chevron_right, color: colors.subtitleText),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FeedbackScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('About App', style: _sectionStyle(colors)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.borderColor),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 14,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: colors.chipBackground,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      color: colors.primaryPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CareerMate AI',
                                          style: _valueStyle(colors),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Version 1.0.0 (Build 1)',
                                          style: _labelStyle(colors),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _confirmLogout,
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontFamilyFallback: ['sans-serif'],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: colors.bottomNavBg,
            selectedItemColor: colors.primaryPurple,
            unselectedItemColor: colors.subtitleText,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: ['sans-serif'],
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: ['sans-serif'],
              fontWeight: FontWeight.w600,
            ),
            onTap: (index) {
              if (index == _selectedIndex) return;
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalysisScreen()),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics_rounded),
                label: 'Analysis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
