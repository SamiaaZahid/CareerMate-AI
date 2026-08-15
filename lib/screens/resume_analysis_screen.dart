import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/recommendation_item.dart';
import '../services/db_service.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'program_details_screen.dart';

const Color kAnalysisBackgroundColor = Color(0xFFF5F5F7);
const Color kAnalysisPrimaryColor = AppColors.primaryPurple;
const Color kAnalysisBorderColor = Color(0xFFE8E1F5);
const Color kAnalysisInactiveColor = Color(0xFF8B8B98);
const TextStyle kAnalysisCardTitleStyle = TextStyle(
  fontFamily: 'Be Vietnam Pro',
  fontFamilyFallback: ['sans-serif'],
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1F1F28),
);

class ResumeAnalysisScreen extends StatefulWidget {
  const ResumeAnalysisScreen({super.key});

  @override
  State<ResumeAnalysisScreen> createState() => _ResumeAnalysisScreenState();
}

class _ResumeAnalysisScreenState extends State<ResumeAnalysisScreen> {
  int _selectedIndex = 1;

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

  TextStyle get _bodyStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 14,
        color: Color(0xFF6F6F7B),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAnalysisBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAnalysisPrimaryColor,
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
              const Center(
                child: Text(
                  'Resume Analysis',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontFamilyFallback: ['sans-serif'],
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kAnalysisPrimaryColor,
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
                        style: _bodyStyle,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search jobs or keywords',
                          prefixIcon: const Icon(Icons.search, color: AppColors.accentOrange),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
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
                              backgroundColor: kAnalysisPrimaryColor,
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
              const Center(
                child: _ScoreRing(
                  scoreText: '78 / 100',
                  progress: 0.78,
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
              const _BulletCard(
                title: 'Strengths',
                icon: Icons.check_circle_rounded,
                iconColor: Color(0xFF2FA84F),
                bullets: [
                  'Strong project section with clear outcomes',
                  'Relevant technical keywords already included',
                  'Good structure and readable formatting',
                ],
                bulletIcon: Icons.star_rounded,
              ),
              const SizedBox(height: 16),
              const _BulletCard(
                title: 'Areas for Improvement',
                icon: Icons.warning_amber_rounded,
                iconColor: Color(0xFFE08A1E),
                bullets: [
                  'Add more measurable achievements and metrics',
                  'Highlight cloud and deployment experience',
                  'Include collaboration and leadership examples',
                ],
                bulletIcon: Icons.arrow_right_alt_rounded,
              ),
              const SizedBox(height: 16),
              _SkillsSection(
                title: 'Missing Skills Detected',
                chips: _missingSkills,
              ),
              const SizedBox(height: 16),
              _RecommendationSection(
                title: 'Recommended Internships',
                icon: Icons.work_outline,
                items: _internships,
              ),
              const SizedBox(height: 16),
              _RecommendationSection(
                title: 'Recommended Scholarships',
                icon: Icons.school_outlined,
                items: _scholarships,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kAnalysisPrimaryColor,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings coming soon')),
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
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.scoreText, required this.progress});

  final String scoreText;
  final double progress;

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
                backgroundColor: const Color(0xFFE8E1F6),
                progressColor: kAnalysisPrimaryColor,
              ),
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
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
                style: const TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontFamilyFallback: ['sans-serif'],
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kAnalysisPrimaryColor,
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
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> bullets;
  final IconData bulletIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAnalysisBorderColor),
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
              Expanded(child: Text(title, style: kAnalysisCardTitleStyle)),
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
                    color: kAnalysisPrimaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: ['sans-serif'],
                        fontSize: 14,
                        color: Color(0xFF5F5F6B),
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
  const _SkillsSection({required this.title, required this.chips});

  final String title;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAnalysisBorderColor),
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
          Text(title, style: kAnalysisCardTitleStyle),
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
                      color: const Color(0xFFF2EDFC),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: kAnalysisBorderColor),
                    ),
                    child: Text(
                      chip,
                      style: const TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: ['sans-serif'],
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kAnalysisPrimaryColor,
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
  });

  final String title;
  final IconData icon;
  final List<RecommendationItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAnalysisBorderColor),
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
              Icon(icon, color: kAnalysisPrimaryColor, size: 22),
              const SizedBox(width: 8),
              Text(title, style: kAnalysisCardTitleStyle),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFDFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9E4F7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: ['sans-serif'],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F28),
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
