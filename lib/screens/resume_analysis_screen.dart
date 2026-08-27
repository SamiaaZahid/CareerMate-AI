
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../services/internship_service.dart';

import '../constants/app_colors.dart';
import '../models/recommendation_item.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/resume_analysis_service.dart';
import '../services/scholarship_service.dart';
import '../services/theme_service.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'program_details_screen.dart';
import 'settings_screen.dart';

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

  // Profile-completeness breakdown (independent of the AI analysis below).
  bool _hasResume = false;
  int _resumeScore = 0;
  int _resumePts = 0;
  int _skillsPts = 0;
  int _skillsCount = 0;
  int _eduPts = 0;
  int _goalsPts = 0;

  // AI-powered resume analysis (Gemini).
  _AnalysisStatus _status = _AnalysisStatus.loading;
  ResumeAnalysisResult? _result;
  String _targetRole = 'Software Engineering';

  // Resume/skill-derived recommendations. Populated by _loadRecommendations()
  // from assets/data/programs.json, matched against the user's stored skills
  // and Gemini's missingSkills — never hardcoded, never static per-user.
  List<RecommendationItemData> _internships = [];
  List<RecommendationItemData> _scholarships = [];
  List<String> _userSkillsList = [];

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    await Future.wait([_loadUserEvaluation(), _loadAndAnalyze()]);
    await _loadRecommendations();
  }

  /// Loads every program from programs.json, scores each one against the
  /// user's stored skills (and, once analysis has run, Gemini's
  /// missingSkills so growth-relevant programs surface too), and keeps only
  /// the strongest matches per type. Falls back to showing the first few
  /// unmatched entries only if literally nothing scored above zero, so the
  /// section is never silently empty — but it's never fabricated either.
  Future<void> _loadRecommendations() async {
    try {
      // Internships: now sourced live from Supabase, matched against
      // the user's skills + Gemini's missingSkills.
      final allInternships = await InternshipService().fetchInternships();

      final matchSkills = <String>{
        ..._userSkillsList.map((s) => s.trim().toLowerCase()),
        if (_result != null) ..._result!.missingSkills.map((s) => s.trim().toLowerCase()),
      }..removeWhere((s) => s.isEmpty);

      List<MapEntry<RecommendationItemData, int>> scoreAndSort(List<RecommendationItemData> items) {
        final entries = items.map((item) {
          var matchCount = 0;
          for (final progSkill in item.skills) {
            final pLower = progSkill.trim().toLowerCase();
            final matched = matchSkills.any(
              (uSkill) => pLower == uSkill || pLower.contains(uSkill) || uSkill.contains(pLower),
            );
            if (matched) matchCount++;
          }
          return MapEntry(item, matchCount);
        }).toList();
        entries.sort((a, b) => b.value.compareTo(a.value));
        return entries;
      }

      List<RecommendationItemData> topThree(List<MapEntry<RecommendationItemData, int>> scored) {
        final matched = scored.where((e) => e.value > 0).toList();
        final source = matched.isNotEmpty ? matched : scored;
        return source.take(3).map((e) => e.key).toList();
      }

      // Scholarships: scholarships.json (the single source of truth also
      // used by the Scholarships tab) via the shared Scholarship model.
      // That dataset has no skill tags, so we don't fabricate a skill
      // match score for it — we just show the real, current set.
      final scholarships = await ScholarshipService().fetchScholarships();
      final scholarshipItems = scholarships
          .map((s) => RecommendationItemData.fromScholarship(s))
          .take(3)
          .toList();

      if (!mounted) return;
      setState(() {
        _internships = topThree(scoreAndSort(allInternships));
        _scholarships = scholarshipItems;
      });
    } catch (e) {
      debugPrint('[ResumeAnalysisScreen] Failed to load recommendations: $e');
    }
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
          _userSkillsList = skillsList;
        });
      }
    }
  }

  /// Loads the logged-in user's extracted resume text from the DB and,
  /// if present, sends it to Gemini for real analysis. Every state here
  /// reflects what's actually in the user's row and what Gemini returned.
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
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, _) {
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
                            'Based on your uploaded resume for a $_targetRole role, here is your AI-powered evaluation.',
                            textAlign: TextAlign.center,
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              color: colors.primaryText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search jobs or keywords',
                              hintStyle: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                color: colors.subtitleText,
                              ),
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
                  _buildBreakdownCard(colors),
                  const SizedBox(height: 16),
                  _buildAnalysisSection(colors),
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
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              } else if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
            'Profile Completeness',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_resumeScore / 100 pts based on your profile',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 12,
              color: colors.subtitleText,
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

  /// Renders the AI score ring + strengths/improvements/missing-skills
  /// cards, or an appropriate loading/empty/error state in their place.
  Widget _buildAnalysisSection(AppThemeColors colors) {
    switch (_status) {
      case _AnalysisStatus.loading:
        return _AnalysisLoadingState(colors: colors);

      case _AnalysisStatus.noResume:
        return _AnalysisEmptyState(
          colors: colors,
          onUploadPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        );

      case _AnalysisStatus.error:
        return _AnalysisErrorState(
          colors: colors,
          onRetry: _initLoad,
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
                colors: colors,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'AI Resume Score',
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontFamilyFallback: const ['sans-serif'],
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.primaryText,
                ),
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
                colors: colors,
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
                colors: colors,
              ),
              const SizedBox(height: 16),
            ],
            if (result.missingSkills.isNotEmpty)
              _SkillsSection(
                title: 'Missing Skills Detected',
                chips: result.missingSkills,
                colors: colors,
              ),
          ],
        );
    }
  }
}

class _AnalysisLoadingState extends StatelessWidget {
  const _AnalysisLoadingState({required this.colors});

  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: colors.primaryPurple),
            const SizedBox(height: 16),
            Text(
              'Analyzing your resume…',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: const ['sans-serif'],
                fontSize: 14,
                color: colors.subtitleText,
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
    required this.colors,
    required this.onUploadPressed,
  });

  final AppThemeColors colors;
  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.description_outlined, color: colors.primaryPurple, size: 40),
          const SizedBox(height: 12),
          Text(
            'No resume found yet',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: const ['sans-serif'],
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload a PDF or DOCX resume in your Profile to get a real AI-powered analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: const ['sans-serif'],
              fontSize: 13,
              color: colors.subtitleText,
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
    required this.colors,
    required this.onRetry,
  });

  final AppThemeColors colors;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE05A5A), size: 40),
          const SizedBox(height: 12),
          Text(
            "Couldn't analyze your resume",
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: const ['sans-serif'],
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Something went wrong reaching the AI service. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: const ['sans-serif'],
              fontSize: 13,
              color: colors.subtitleText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryPurple,
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