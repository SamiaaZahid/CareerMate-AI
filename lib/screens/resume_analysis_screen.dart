import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/recommendation_item.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/resume_analysis_service.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'program_details_screen.dart';
import 'settings_screen.dart';

const Color kAnalysisPrimaryColor = AppColors.primaryPurple;
const Color kAnalysisBorderColor = Color(0xFFE8E1F5);
const Color kAnalysisInactiveColor = Color(0xFF8B8B98);

/// Which phase of loading/analysis the screen is currently showing.
enum _AnalysisStatus {
  loading,
  noResume,
  error,
  ready,
}

class ResumeAnalysisScreen extends StatefulWidget {
  const ResumeAnalysisScreen({super.key});

  @override
  State<ResumeAnalysisScreen> createState() => _ResumeAnalysisScreenState();
}

class _ResumeAnalysisScreenState extends State<ResumeAnalysisScreen> {
  int _selectedIndex = 1;

  _AnalysisStatus _status = _AnalysisStatus.loading;
  ResumeAnalysisResult? _result;
  String _targetRole = 'Software Engineering';

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

  TextStyle get _bodyStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 14,
        color: Color(0xFF6F6F7B),
      );

  @override
  void initState() {
    super.initState();
    _loadAndAnalyze();
  }

  /// Loads the logged-in user's extracted resume text from the DB and,
  /// if present, sends it to Gemini for real analysis. Replaces the old
  /// hardcoded 78/100 mock — every state here reflects what's actually
  /// in the user's row and what Gemini actually returned.
  Future<void> _loadAndAnalyze() async {
    if (mounted) {
      setState(() => _status = _AnalysisStatus.loading);
    }

    final userId = AuthService.instance.currentUserId;
    debugPrint('[ResumeAnalysisScreen] Active userId: $userId');
    if (userId == null) {
      if (!mounted) return;
      setState(() => _status = _AnalysisStatus.noResume);
      return;
    }

    final user = await DbService.instance.getUserById(userId);
    final resumeText = (user?['resume_text'] as String?) ?? '';
    debugPrint('[ResumeAnalysisScreen] resume_text length from DB: ${resumeText.length}');

    final degree = (user?['degree'] as String?)?.trim();
    final targetRole = (degree != null && degree.isNotEmpty) ? degree : 'Software Engineering';
    debugPrint('[ResumeAnalysisScreen] Target role for analysis: $targetRole');

    if (resumeText.trim().isEmpty) {
      if (!mounted) return;
      setState(() => _status = _AnalysisStatus.noResume);
      return;
    }

    final result = await ResumeAnalysisService.instance.analyze(resumeText: resumeText, targetRole: targetRole);
    if (!mounted) return;

    if (result == null) {
      debugPrint('[ResumeAnalysisScreen] Analysis failed or returned null.');
      setState(() => _status = _AnalysisStatus.error);
    } else {
      debugPrint('[ResumeAnalysisScreen] Analysis succeeded. Score: ${result.score}');
      setState(() {
        _result = result;
        _targetRole = targetRole;
        _status = _AnalysisStatus.ready;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF9D7BEE) : kAnalysisPrimaryColor;
    final cardBorder = isDark ? const Color(0xFF2C2C35) : kAnalysisBorderColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : kAnalysisPrimaryColor,
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
                    color: primaryColor,
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
                        'Based on your uploaded resume for a $_targetRole role, here is your AI-powered evaluation.',
                        textAlign: TextAlign.center,
                        style: _bodyStyle,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search jobs or keywords',
                          hintStyle: const TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            color: Color(0xFF9A9AA6),
                          ),
                          prefixIcon: const Icon(Icons.search, color: AppColors.accentOrange),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cardBorder),
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
                              backgroundColor: primaryColor,
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
              _buildAnalysisSection(primaryColor: primaryColor, cardBorder: cardBorder),
              const SizedBox(height: 16),
              _RecommendationSection(
                title: 'Recommended Internships',
                icon: Icons.work_outline,
                items: _internships,
                borderColor: cardBorder,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
              _RecommendationSection(
                title: 'Recommended Scholarships',
                icon: Icons.school_outlined,
                items: _scholarships,
                borderColor: cardBorder,
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: primaryColor,
        unselectedItemColor: kAnalysisInactiveColor,
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
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            }
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
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
  }

  /// Renders the score ring + strengths/improvements/missing-skills
  /// cards, or an appropriate loading/empty/error state in their place.
  Widget _buildAnalysisSection({
    required Color primaryColor,
    required Color cardBorder,
  }) {
    switch (_status) {
      case _AnalysisStatus.loading:
        return _AnalysisLoadingState(primaryColor: primaryColor);

      case _AnalysisStatus.noResume:
        return _AnalysisEmptyState(
          primaryColor: primaryColor,
          borderColor: cardBorder,
          onUploadPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        );

      case _AnalysisStatus.error:
        return _AnalysisErrorState(
          primaryColor: primaryColor,
          borderColor: cardBorder,
          onRetry: _loadAndAnalyze,
        );

      case _AnalysisStatus.ready:
        final result = _result!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: _ScoreRing(
                scoreText: '${result.score} / 100',
                progress: result.score / 100,
                primaryColor: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Resume Score',
                style: _bodyStyle.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 24),
            if (result.strengths.isNotEmpty) ...[
              _BulletCard(
                title: 'Strengths',
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF2FA84F),
                bullets: result.strengths,
                bulletIcon: Icons.star_rounded,
                borderColor: cardBorder,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
            ],
            if (result.improvements.isNotEmpty) ...[
              _BulletCard(
                title: 'Areas for Improvement',
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFE08A1E),
                bullets: result.improvements,
                bulletIcon: Icons.arrow_right_alt_rounded,
                borderColor: cardBorder,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
            ],
            if (result.missingSkills.isNotEmpty)
              _SkillsSection(
                title: 'Missing Skills Detected',
                chips: result.missingSkills,
                borderColor: cardBorder,
                primaryColor: primaryColor,
              ),
          ],
        );
    }
  }
}

class _AnalysisLoadingState extends StatelessWidget {
  const _AnalysisLoadingState({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text(
              'Analyzing your resume…',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: const ['sans-serif'],
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisEmptyState extends StatelessWidget {
  const _AnalysisEmptyState({
    required this.primaryColor,
    required this.borderColor,
    required this.onUploadPressed,
  });

  final Color primaryColor;
  final Color borderColor;
  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.description_outlined, color: primaryColor, size: 40),
          const SizedBox(height: 12),
          Text(
            'No resume found yet',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: const ['sans-serif'],
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload a PDF or DOCX resume in your Profile to get a real AI-powered analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: ['sans-serif'],
              fontSize: 13,
              color: Color(0xFF6F6F7B),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onUploadPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Go to Profile',
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontFamilyFallback: ['sans-serif'],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisErrorState extends StatelessWidget {
  const _AnalysisErrorState({
    required this.primaryColor,
    required this.borderColor,
    required this.onRetry,
  });

  final Color primaryColor;
  final Color borderColor;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE05A5A), size: 40),
          const SizedBox(height: 12),
          Text(
            'Couldn\'t analyze your resume',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: const ['sans-serif'],
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Something went wrong reaching the AI service. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: ['sans-serif'],
              fontSize: 13,
              color: Color(0xFF6F6F7B),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontFamilyFallback: ['sans-serif'],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.scoreText,
    required this.progress,
    required this.primaryColor,
  });

  final String scoreText;
  final double progress;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                backgroundColor: isDark ? const Color(0xFF2C2C35) : const Color(0xFFE8E1F6),
                progressColor: primaryColor,
              ),
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                  color: primaryColor,
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
    required this.borderColor,
    required this.primaryColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> bullets;
  final IconData bulletIcon;
  final Color borderColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
                    fontFamilyFallback: const ['sans-serif'],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
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
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: const ['sans-serif'],
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFB0B0C0) : const Color(0xFF5F5F6B),
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
    required this.borderColor,
    required this.primaryColor,
  });

  final String title;
  final List<String> chips;
  final Color borderColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? const Color(0xFF2C2540) : const Color(0xFFF2EDFC);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
              fontFamilyFallback: const ['sans-serif'],
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
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
                      color: iconBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: const ['sans-serif'],
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
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
    required this.borderColor,
    required this.primaryColor,
  });

  final String title;
  final IconData icon;
  final List<RecommendationItemData> items;
  final Color borderColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subCardBg = isDark ? const Color(0xFF262630) : const Color(0xFFFDFDFF);
    final subCardBorder = isDark ? const Color(0xFF333340) : const Color(0xFFE9E4F7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
              Icon(icon, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontFamilyFallback: const ['sans-serif'],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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
                  color: subCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: subCardBorder),
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: ['sans-serif'],
                        fontSize: 13,
                        color: Color(0xFF6F6F7B),
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
                          'View',
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