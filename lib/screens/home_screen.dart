import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/theme_service.dart';
import 'profile_screen.dart';
import 'program_listing_screen.dart';
import 'resume_analysis_screen.dart';
import 'settings_screen.dart';
import '../scholarships_screen.dart';
import '../skill_roadmap_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String? _profileName;
  int _completenessPercentage = 0;
  String _resumeStatusText = 'No CV uploaded yet';
  bool _hasResume = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _profileName = null;
        _completenessPercentage = 0;
        _resumeStatusText = 'No CV uploaded yet';
        _hasResume = false;
      });
      return;
    }

    final user = await DbService.instance.getUserById(userId);
    if (!mounted) return;
    if (user == null) return;

    final name = (user['name'] as String?)?.trim();
    final degree = (user['degree'] as String?)?.trim();
    final college = (user['college'] as String?)?.trim();
    final year = (user['year_of_study'] as String?)?.trim();
    final location = (user['preferred_location'] as String?)?.trim();
    final skills = (user['skills'] as String?)?.trim();
    final goals = (user['career_goals'] as String?)?.trim();
    final resumePath = (user['resume_path'] as String?)?.trim();

    int score = 0;
    if (name != null && name.isNotEmpty) score += 15;
    if (degree != null && degree.isNotEmpty) score += 15;
    if (college != null && college.isNotEmpty) score += 15;
    if (year != null && year.isNotEmpty) score += 10;
    if (location != null && location.isNotEmpty) score += 15;
    if (skills != null && skills.isNotEmpty) score += 15;
    if (goals != null && goals.isNotEmpty) score += 15;

    final bool resumeExists = resumePath != null && resumePath.isNotEmpty;

    setState(() {
      _profileName = (name != null && name.isNotEmpty) ? name : null;
      _completenessPercentage = score;
      _hasResume = resumeExists;
      _resumeStatusText = resumeExists
          ? 'CV uploaded (${resumePath.split(RegExp(r'[/\\]')).last})'
          : 'No CV uploaded yet';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, _) {
        final colors = ThemeService.instance.colors;

        final headlineStyle = TextStyle(
          fontFamily: 'Be Vietnam Pro',
          fontFamilyFallback: const ['sans-serif'],
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: colors.primaryText,
        );

        final sectionStyle = TextStyle(
          fontFamily: 'Be Vietnam Pro',
          fontFamilyFallback: const ['sans-serif'],
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colors.primaryText,
        );

        final cardTitleStyle = TextStyle(
          fontFamily: 'Be Vietnam Pro',
          fontFamilyFallback: const ['sans-serif'],
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: colors.primaryText,
        );

        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: const Text(
              'CareerMate AI',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: ['sans-serif'],
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                tooltip: 'Profile',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  _loadUserData();
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6B4FCB),
                    AppColors.primaryPurple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profileName != null ? 'Welcome, $_profileName 👋' : 'Welcome back 👋',
                    style: headlineStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your career progress and explore opportunities.',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontFamilyFallback: const ['sans-serif'],
                      fontSize: 14,
                      color: colors.subtitleText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _StatusCard(
                    title: 'Profile Completeness',
                    titleStyle: sectionStyle,
                    borderColor: colors.borderColor,
                    cardBg: colors.surfaceCard,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                      _loadUserData();
                    },
                    content: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.chipBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '$_completenessPercentage%',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontFamilyFallback: const ['sans-serif'],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.primaryPurple,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _completenessPercentage == 100
                                    ? 'Profile Complete!'
                                    : 'Profile Completeness — Tap to update',
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontFamilyFallback: const ['sans-serif'],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: _completenessPercentage / 100,
                                  minHeight: 8,
                                  backgroundColor: colors.chipBackground,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colors.primaryPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatusCard(
                    title: 'CV Status',
                    titleStyle: sectionStyle,
                    borderColor: colors.borderColor,
                    cardBg: colors.surfaceCard,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                      _loadUserData();
                    },
                    content: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.chipBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _hasResume ? Icons.description_rounded : Icons.upload_file_rounded,
                            color: AppColors.accentOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _resumeStatusText,
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontFamilyFallback: const ['sans-serif'],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _hasResume ? 'Tap to view or edit profile' : 'Upload your resume in profile',
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontFamilyFallback: const ['sans-serif'],
                                  fontSize: 12,
                                  color: colors.subtitleText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Explore Tools', style: sectionStyle),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _ToolCard(
                        icon: Icons.document_scanner_outlined,
                        label: 'Resume Analysis',
                        labelStyle: cardTitleStyle,
                        cardBg: colors.surfaceCard,
                        borderColor: colors.borderColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResumeAnalysisScreen(),
                            ),
                          );
                        },
                      ),
                      _ToolCard(
                        icon: Icons.work_outline_rounded,
                        label: 'Internships',
                        labelStyle: cardTitleStyle,
                        cardBg: colors.surfaceCard,
                        borderColor: colors.borderColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProgramListingScreen(),
                            ),
                          );
                        },
                      ),
                      _ToolCard(
                        icon: Icons.school_outlined,
                        label: 'Scholarships',
                        labelStyle: cardTitleStyle,
                        cardBg: colors.surfaceCard,
                        borderColor: colors.borderColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScholarshipsScreen(),
                            ),
                          );
                        },
                      ),
                      _ToolCard(
                        icon: Icons.map_outlined,
                        label: 'Skill Roadmap',
                        labelStyle: cardTitleStyle,
                        cardBg: colors.surfaceCard,
                        borderColor: colors.borderColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SkillRoadmapScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: const Color(0xFF5B3FA8),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'AI Career Chat',
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontFamilyFallback: ['sans-serif'],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
            onTap: (index) async {
              if (index == 0) return;
              setState(() {
                _selectedIndex = index;
              });
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResumeAnalysisScreen(),
                  ),
                );
              } else if (index == 2) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
                _loadUserData();
              } else if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.titleStyle,
    required this.borderColor,
    required this.cardBg,
    required this.content,
    this.onTap,
  });

  final String title;
  final TextStyle titleStyle;
  final Color borderColor;
  final Color cardBg;
  final Widget content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle),
              const SizedBox(height: 14),
              content,
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.label,
    required this.labelStyle,
    required this.cardBg,
    required this.borderColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final TextStyle labelStyle;
  final Color cardBg;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(label, style: labelStyle),
            ],
          ),
        ),
      ),
    );
  }
}