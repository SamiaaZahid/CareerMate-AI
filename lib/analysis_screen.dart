import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/app_colors.dart';
import 'models/recommendation_item.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/program_details_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';
import 'services/db_service.dart';
import 'services/theme_service.dart';

class MatchedProgram {
  final RecommendationItemData item;
  final List<String> matchedSkills;

  MatchedProgram({
    required this.item,
    required this.matchedSkills,
  });
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _selectedIndex = 1;
  bool _isLoading = true;
  List<String> _userSkills = [];
  List<MatchedProgram> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = AuthService.instance.currentUserId;
      if (userId != null) {
        final userData = await DbService.instance.getUserById(userId);
        if (userData != null && userData['skills'] != null) {
          final storedSkills = (userData['skills'] as String).trim();
          if (storedSkills.isNotEmpty) {
            _userSkills = storedSkills
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
          }
        }
      }

      String jsonString = '';
      try {
        jsonString = await rootBundle.loadString('assets/data/programs.json');
      } catch (_) {
        jsonString = await rootBundle.loadString('lib/data/internships.json');
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final allItems = jsonList
          .map((e) => RecommendationItemData.fromJson(e as Map<String, dynamic>))
          .toList();

      final List<MatchedProgram> matchedList = [];

      if (_userSkills.isNotEmpty) {
        final userSkillSet =
            _userSkills.map((s) => s.trim().toLowerCase()).toSet();

        for (final item in allItems) {
          final matches = <String>[];

          for (final progSkill in item.skills) {
            final pLower = progSkill.trim().toLowerCase();
            for (final uSkill in userSkillSet) {
              if (pLower == uSkill ||
                  pLower.contains(uSkill) ||
                  uSkill.contains(pLower)) {
                if (!matches.contains(progSkill)) {
                  matches.add(progSkill);
                }
              }
            }
          }

          if (matches.isNotEmpty) {
            matchedList.add(MatchedProgram(
              item: item,
              matchedSkills: matches,
            ));
          }
        }

        matchedList.sort((a, b) =>
            b.matchedSkills.length.compareTo(a.matchedSkills.length));
      }

      setState(() {
        _recommendations = matchedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
            elevation: 0,
            foregroundColor: Colors.white,
            title: const Text(
              'Analysis',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colors.primaryPurple,
                    ),
                  )
                : RefreshIndicator(
                    color: colors.primaryPurple,
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: colors.surfaceCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.borderColor),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colors.chipBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.analytics_outlined,
                                        color: colors.primaryPurple,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Profile Skill Analysis',
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
                                if (_userSkills.isNotEmpty) ...[
                                  Text(
                                    'Matched programs based on your profile skills:',
                                    style: TextStyle(
                                      fontFamily: 'Be Vietnam Pro',
                                      fontSize: 13,
                                      color: colors.subtitleText,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _userSkills
                                        .map(
                                          (skill) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colors.chipBackground,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              skill,
                                              style: TextStyle(
                                                fontFamily: 'Be Vietnam Pro',
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: colors.primaryPurple,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ] else ...[
                                  Text(
                                    'No skills set on your profile yet.',
                                    style: TextStyle(
                                      fontFamily: 'Be Vietnam Pro',
                                      fontSize: 13,
                                      color: colors.subtitleText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_userSkills.isEmpty || _recommendations.isEmpty)
                            _buildEmptyState(context, colors)
                          else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recommended for You',
                                  style: TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primaryText,
                                  ),
                                ),
                                Text(
                                  '${_recommendations.length} matched',
                                  style: TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colors.primaryPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _recommendations.length,
                              itemBuilder: (context, index) {
                                final match = _recommendations[index];
                                return _ProgramRecommendationCard(
                                  match: match,
                                  colors: colors,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProgramDetailsScreen(item: match.item),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ],
                      ),
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
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
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
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
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
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppThemeColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.chipBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 38,
              color: colors.primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Personalized Recommendations',
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userSkills.isEmpty
                ? 'Add skills to your profile to get personalized recommendations tailored to your career goals.'
                : 'No programs currently match your exact skills. Try adding more skills to your profile!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 14,
              height: 1.4,
              color: colors.subtitleText,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Go to Profile',
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramRecommendationCard extends StatelessWidget {
  const _ProgramRecommendationCard({
    required this.match,
    required this.colors,
    required this.onTap,
  });

  final MatchedProgram match;
  final AppThemeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = match.item;
    final isInternship = item.type == RecommendationType.internship;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.chipBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: colors.primaryPurple,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Matches: ${match.matchedSkills.join(', ')}',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colors.primaryPurple,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isInternship
                      ? const Color(0xFFFFF4E5)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isInternship ? 'Internship' : 'Scholarship',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isInternship
                        ? AppColors.accentOrange
                        : const Color(0xFF2FA84F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 13,
              color: colors.subtitleText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 13,
              height: 1.4,
              color: colors.subtitleText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (item.location != null)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colors.subtitleText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location!,
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 12,
                            color: colors.subtitleText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
