import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/recommendation_item.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/theme_service.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'program_details_screen.dart';
import 'settings_screen.dart';

class ResumeAnalysisScreen extends StatefulWidget {
  const ResumeAnalysisScreen({super.key});

  @override
  State<ResumeAnalysisScreen> createState() => _ResumeAnalysisScreenState();
}

class _ResumeAnalysisScreenState extends State<ResumeAnalysisScreen> {
  int _selectedIndex = 1;
  bool _hasResume = false;
  int _resumeScore = 0;
  int _resumePts = 0;
  int _skillsPts = 0;
  int _skillsCount = 0;
  int _eduPts = 0;
  int _goalsPts = 0;

  @override
  void initState() {
    super.initState();
    _loadUserEvaluation();
  }

  Future<void> _loadUserEvaluation() async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) return;

    final user = await DbService.instance.getUserById(userId);
    if (user != null) {
      final resumePath = (user['resume_path'] as String?)?.trim();
      final hasResume = resumePath != null && resumePath.isNotEmpty;

      final skillsStr = (user['skills'] as String?)?.trim() ?? '';
      final skillsList = skillsStr.isEmpty
          ? <String>[]
          : skillsStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      final degree = (user['degree'] as String?)?.trim() ?? '';
      final college = (user['college'] as String?)?.trim() ?? '';
      final goals = (user['career_goals'] as String?)?.trim() ?? '';

      final resumePts = hasResume ? 30 : 0;
      final skillsPts = (skillsList.length * 6).clamp(0, 30);
      final eduPts = (degree.isNotEmpty ? 10 : 0) + (college.isNotEmpty ? 10 : 0);
      final goalsPts = goals.isNotEmpty ? 20 : 0;

      final totalScore = resumePts + skillsPts + eduPts + goalsPts;

      if (mounted) {
        setState(() {
          _hasResume = hasResume;
          _resumePts = resumePts;
          _skillsPts = skillsPts;
          _skillsCount = skillsList.length;
          _eduPts = eduPts;
          _goalsPts = goalsPts;
          _resumeScore = totalScore;
        });
      }
    }
  }

  final List<String> _missingSkills = const [
    'AWS / Cloud Services',
    'Docker / Containerization',
    'CI/CD Pipelines',
  ];

  final List<RecommendationItemData> _internships = const [
    RecommendationItemData(
      type: RecommendationType.internship,
      title: 'Software Engineering Intern',
      subtitle: 'Google - Jun 2026 to Aug 2026',
      description:
          'Work alongside senior engineers on production systems, contribute to '
          'code reviews, and ship small features end-to-end during a 10-week '
          'summer internship.',
      requirements: [
        'Currently pursuing a degree in Computer Science or related field',
        'Comfortable with at least one OOP language (Java, Python, C++)',
        'Strong problem-solving and communication skills',
      ],
      location: 'Mountain View, CA (Hybrid)',
      deadline: 'Applications close 15 Sep 2026',
    ),
    RecommendationItemData(
      type: RecommendationType.internship,
      title: 'Frontend Intern',
      subtitle: 'Notion - Jul 2026 to Sep 2026',
      description:
          'Help build delightful, accessible UI components used by millions of '
          'users, working closely with design and product teams.',
      requirements: [
        'Experience with React or a similar component-based framework',
        'Eye for detail in UI/UX implementation',
        'Portfolio or GitHub with frontend projects',
      ],
      location: 'Remote',
      deadline: 'Applications close 20 Sep 2026',
    ),
  ];

  final List<RecommendationItemData> _scholarships = const [
    RecommendationItemData(
      type: RecommendationType.scholarship,
      title: 'STEM Excellence Scholarship',
      subtitle: '\$800 - Deadline: 30 Sep 2026',
      description:
          'Awarded to students demonstrating strong academic performance and '
          'active involvement in STEM projects or research.',
      requirements: [
        'Minimum GPA of 3.3 or equivalent',
        'Enrolled in a STEM undergraduate program',
        'One recommendation letter from a faculty member',
      ],
      deadline: '30 Sep 2026',
    ),
    RecommendationItemData(
      type: RecommendationType.scholarship,
      title: 'Future Builders Grant',
      subtitle: '\$600 - Deadline: 12 Oct 2026',
      description:
          'Supports students building independent technical projects or '
          'startups alongside their studies.',
      requirements: [
        'Submit a short project proposal or existing project link',
        'Currently enrolled in an accredited institution',
        'Open to all fields of study',
      ],
      deadline: '12 Oct 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, themeMode, _) {
        final colors = ThemeService.instance.colors;
        final bodyStyle = TextStyle(
          fontFamily: 'Be Vietnam Pro',
          fontFamilyFallback: const ['sans-serif'],
          fontSize: 14,
          color: colors.subtitleText,
        );

        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: colors.appBarBackground,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'CareerMate AI',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: ['sans-serif'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Resume Analysis',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: const ['sans-serif'],
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        children: [
                          Text(
                            'Based on your uploaded resume for a Software Engineering role, here is your AI-powered evaluation.',
                            textAlign: TextAlign.center,
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            style: TextStyle(color: colors.primaryText),
                            decoration: InputDecoration(
                              hintText: 'Search jobs or keywords',
                              hintStyle: TextStyle(color: colors.subtitleText),
                              prefixIcon: const Icon(Icons.search, color: AppColors.accentOrange),
                              filled: true,
                              fillColor: colors.surfaceCard,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colors.primaryPurple, width: 1.4),
                              ),
                            ),
                            onSubmitted: (q) async {
                              if (q.trim().isEmpty) return;
                              final messenger = ScaffoldMessenger.of(context);
                              final double snackLeft = MediaQuery.of(context).size.width * 0.5;
                              final userId = AuthService.instance.currentUserId;
                              if (userId == null) {
                                messenger.showSnackBar(const SnackBar(content: Text('Please log in to save searches')));
                                return;
                              }
                              await DbService.instance.addSearch(userId, q.trim());
                              if (!context.mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.only(left: snackLeft, bottom: 16, right: 16),
                                  backgroundColor: colors.primaryPurple,
                                  content: Text('Saved search: $q', style: const TextStyle(color: Colors.white)),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: _ScoreRing(
                      scoreText: '$_resumeScore / 100',
                      progress: _resumeScore / 100,
                      colors: colors,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Resume Score',
                      style: bodyStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primaryText,
                      ),
                    ),
                  ),
                  if (!_hasResume) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.chipBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.borderColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.accentOrange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No resume uploaded yet. Upload a CV on your Profile page to boost your score by +30 points!',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 13,
                                color: colors.subtitleText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildBreakdownCard(colors),
                  const SizedBox(height: 24),
                  _BulletCard(
                    title: 'Strengths',
                    icon: Icons.check_circle_rounded,
                    iconColor: const Color(0xFF2FA84F),
                    bullets: const [
                      'Strong project section with clear outcomes',
                      'Relevant technical keywords already included',
                      'Good structure and readable formatting',
                    ],
                    bulletIcon: Icons.star_rounded,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _BulletCard(
                    title: 'Areas for Improvement',
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFE08A1E),
                    bullets: const [
                      'Add more measurable achievements and metrics',
                      'Highlight cloud and deployment experience',
                      'Include collaboration and leadership examples',
                    ],
                    bulletIcon: Icons.arrow_right_alt_rounded,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _SkillsSection(
                    title: 'Missing Skills Detected',
                    chips: _missingSkills,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _RecommendationSection(
                    title: 'Recommended Internships',
                    icon: Icons.work_outline,
                    items: _internships,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _RecommendationSection(
                    title: 'Recommended Scholarships',
                    icon: Icons.school_outlined,
                    items: _scholarships,
                    colors: colors,
                  ),
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
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
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

  Widget _buildBreakdownCard(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Breakdown',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 14),
          _breakdownRow(
            icon: Icons.description_outlined,
            title: 'Resume Uploaded',
            subtitle: _hasResume ? 'CV attached' : 'No CV uploaded',
            pointsText: '$_resumePts / 30 pts',
            isFulfilled: _hasResume,
            colors: colors,
          ),
          Divider(height: 20, color: colors.borderColor),
          _breakdownRow(
            icon: Icons.psychology_outlined,
            title: 'Key Skills Listed',
            subtitle: '$_skillsCount skills added',
            pointsText: '$_skillsPts / 30 pts',
            isFulfilled: _skillsPts > 0,
            colors: colors,
          ),
          Divider(height: 20, color: colors.borderColor),
          _breakdownRow(
            icon: Icons.school_outlined,
            title: 'Education & Institution',
            subtitle: 'Degree & College info',
            pointsText: '$_eduPts / 20 pts',
            isFulfilled: _eduPts > 0,
            colors: colors,
          ),
          Divider(height: 20, color: colors.borderColor),
          _breakdownRow(
            icon: Icons.flag_outlined,
            title: 'Career Goals',
            subtitle: 'Defined in profile',
            pointsText: '$_goalsPts / 20 pts',
            isFulfilled: _goalsPts > 0,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String pointsText,
    required bool isFulfilled,
    required AppThemeColors colors,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: isFulfilled ? colors.primaryPurple : colors.subtitleText,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 12,
                  color: colors.subtitleText,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isFulfilled ? colors.chipBackground : colors.inputFillColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            pointsText,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isFulfilled ? colors.primaryPurple : colors.subtitleText,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.scoreText,
    required this.progress,
    required this.colors,
  });

  final String scoreText;
  final double progress;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                backgroundColor: colors.borderColor,
                progressColor: colors.primaryPurple,
              ),
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                scoreText,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontFamilyFallback: const ['sans-serif'],
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        backgroundColor != oldDelegate.backgroundColor ||
        progressColor != oldDelegate.progressColor;
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bullets,
    required this.bulletIcon,
    required this.colors,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> bullets;
  final IconData bulletIcon;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor),
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
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    bulletIcon,
                    size: 18,
                    color: colors.primaryPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: const ['sans-serif'],
                        fontSize: 14,
                        color: colors.subtitleText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({
    required this.title,
    required this.chips,
    required this.colors,
  });

  final String title;
  final List<String> chips;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor),
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
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.chipBackground,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colors.borderColor),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: const ['sans-serif'],
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.primaryPurple,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.colors,
  });

  final String title;
  final IconData icon;
  final List<RecommendationItemData> items;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor),
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
          Row(
            children: [
              Icon(icon, color: colors.primaryPurple, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: const ['sans-serif'],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: const ['sans-serif'],
                        fontSize: 13,
                        color: colors.subtitleText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProgramDetailsScreen(item: item),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontFamilyFallback: ['sans-serif'],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
