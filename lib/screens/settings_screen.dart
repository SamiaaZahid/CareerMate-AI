import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'resume_analysis_screen.dart';

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

  static const Color _backgroundColor = Color(0xFFF5F5F7);
  static const Color _borderColor = Color(0xFFE8E1F5);
  static const Color _inactiveColor = Color(0xFF8B8B98);

  TextStyle get _sectionStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F1F28),
      );

  TextStyle get _labelStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF8B8B98),
      );

  TextStyle get _valueStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F1F28),
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
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
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
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
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
                    Text('Account', style: _sectionStyle),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Full Name', style: _labelStyle),
                          const SizedBox(height: 4),
                          Text(
                            (_name == null || _name!.isEmpty) ? 'Not set' : _name!,
                            style: _valueStyle,
                          ),
                          const SizedBox(height: 16),
                          Text('Email', style: _labelStyle),
                          const SizedBox(height: 4),
                          Text(
                            (_email == null || _email!.isEmpty) ? 'Not set' : _email!,
                            style: _valueStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('About', style: _sectionStyle),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('App', style: _labelStyle),
                          const SizedBox(height: 4),
                          const Text('CareerMate AI', style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontFamilyFallback: ['sans-serif'],
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F1F28),
                          )),
                          const SizedBox(height: 16),
                          Text('Version', style: _labelStyle),
                          const SizedBox(height: 4),
                          const Text('v1.0.0 — Week 2 Prototype', style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontFamilyFallback: ['sans-serif'],
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F1F28),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
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
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: _inactiveColor,
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
              MaterialPageRoute(builder: (context) => const ResumeAnalysisScreen()),
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
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}