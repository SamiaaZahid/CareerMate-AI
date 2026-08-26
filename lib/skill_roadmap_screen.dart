import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_colors.dart';
import 'models/skill_roadmap_model.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';

class SkillStepState {
  final int stepNumber;
  final String title;
  final String description;
  final String resource;
  bool isCompleted;

  SkillStepState({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.resource,
    this.isCompleted = false,
  });
}

class SkillRoadmapScreen extends StatefulWidget {
  const SkillRoadmapScreen({super.key});

  static const Color primaryPurple = Color(0xFF5B3FA8);
  static const Color gradientStart = Color(0xFF6B4FCB);
  static const Color lightLavender = Color(0xFFEDE7FA);
  static const Color backgroundColor = Color(0xFFF7F6FC);
  static const Color borderColor = Color(0xFFE8E1F5);

  @override
  State<SkillRoadmapScreen> createState() => _SkillRoadmapScreenState();
}

class _SkillRoadmapScreenState extends State<SkillRoadmapScreen> {
  final TextEditingController _goalController = TextEditingController();
  List<SkillRoadmapModel> _allRoadmaps = [];
  SkillRoadmapModel? _activeRoadmap;
  List<String> _userProfileSkills = [];
  List<SkillStepState> _activeSteps = [];
  bool _isLoading = true;
  bool _isFallback = false;
  String _fallbackQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // 1. Fetch User Profile Skills
      final user = await AuthService.instance.getCurrentUser();
      List<String> userSkills = [];
      if (user != null) {
        final skillsStr = (user['skills'] as String?)?.trim() ?? '';
        if (skillsStr.isNotEmpty) {
          userSkills = skillsStr
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
      if (userSkills.isEmpty) {
        userSkills = ['Python', 'SQL'];
      }
      _userProfileSkills = userSkills;
      debugPrint('[SkillRoadmap] User profile skills: $_userProfileSkills');

      // 2. Load JSON templates
      try {
        final jsonString =
            await rootBundle.loadString('assets/data/skill_roadmaps.json');
        final Map<String, dynamic> data = json.decode(jsonString);
        final List<dynamic> list = data['roadmaps'] as List<dynamic>? ?? [];
        _allRoadmaps =
            list.map((item) => SkillRoadmapModel.fromJson(item)).toList();
        debugPrint('[SkillRoadmap] Successfully loaded ${_allRoadmaps.length} roadmaps from JSON.');
      } catch (assetError) {
        debugPrint('[SkillRoadmap] Asset load error: $assetError. Using built-in templates.');
        _allRoadmaps = _getFallbackTemplates();
      }

      if (_allRoadmaps.isEmpty) {
        _allRoadmaps = _getFallbackTemplates();
      }

      // 3. Auto-suggest best matching template based on user skills
      SkillRoadmapModel selectedTemplate = _allRoadmaps.first;
      int maxOverlap = 0;

      for (final tmpl in _allRoadmaps) {
        int overlap = 0;
        for (final step in tmpl.steps) {
          final stepTitle = step.title.toLowerCase();
          for (final uSkill in _userProfileSkills) {
            final skillLower = uSkill.toLowerCase();
            if (stepTitle.contains(skillLower) || skillLower.contains(stepTitle)) {
              overlap++;
            }
          }
        }
        if (overlap > maxOverlap) {
          maxOverlap = overlap;
          selectedTemplate = tmpl;
        }
      }

      debugPrint('[SkillRoadmap] Auto-selected roadmap: ${selectedTemplate.role}');
      _activeRoadmap = selectedTemplate;
      _goalController.text = selectedTemplate.role;
      _updateActiveSteps(selectedTemplate);

      setState(() {
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('[SkillRoadmap] Unhandled error in _loadData: $e\n$stack');
      _allRoadmaps = _getFallbackTemplates();
      _activeRoadmap = _allRoadmaps.first;
      _goalController.text = _allRoadmaps.first.role;
      _updateActiveSteps(_allRoadmaps.first);
      setState(() {
        _isLoading = false;
      });
    }
  }

  static List<SkillRoadmapModel> _getFallbackTemplates() {
    return [
      SkillRoadmapModel(
        id: 'data_analyst',
        role: 'Data Analyst',
        aliases: ['data analysis', 'data analyst', 'data analytics', 'data science'],
        description: 'Master data querying, statistical modeling, visualization, and business intelligence.',
        steps: [
          SkillRoadmapStep(stepNumber: 1, title: 'Excel', description: 'Spreadsheet fundamentals, formulas, VLOOKUP/XLOOKUP, and pivot tables.', resource: 'Suggested: Excel Skills for Business (Coursera)'),
          SkillRoadmapStep(stepNumber: 2, title: 'SQL', description: 'Querying and managing relational databases with SELECT, JOINs, and aggregations.', resource: 'Suggested: Practice on LeetCode & HackerRank SQL'),
          SkillRoadmapStep(stepNumber: 3, title: 'Python', description: 'Data manipulation and wrangling with pandas, NumPy, and Jupyter Notebooks.', resource: 'Suggested: Kaggle Pandas Tutorials & NumPy Guides'),
          SkillRoadmapStep(stepNumber: 4, title: 'Statistics', description: 'Core statistical concepts, probability distributions, and hypothesis testing.', resource: 'Suggested: Khan Academy Statistics & Probability'),
          SkillRoadmapStep(stepNumber: 5, title: 'Data Visualization', description: 'Building interactive dashboards with Tableau, Power BI, or Matplotlib.', resource: 'Suggested: Build a Tableau Public sample dashboard'),
          SkillRoadmapStep(stepNumber: 6, title: 'Projects', description: 'Build 2-3 end-to-end portfolio data analysis projects on GitHub.', resource: 'Suggested: Exploratory Data Analysis project on GitHub'),
          SkillRoadmapStep(stepNumber: 7, title: 'Interview Preparation', description: 'Practice live SQL problem solving, case studies, and business analytics questions.', resource: 'Suggested: Mock technical interviews & case study walkthroughs'),
        ],
      ),
      SkillRoadmapModel(
        id: 'full_stack_developer',
        role: 'Full Stack Developer',
        aliases: ['full stack', 'fullstack', 'full stack dev', 'software engineer', 'web developer', 'developer'],
        description: 'Build complete modern web applications from responsive frontends to scalable backends.',
        steps: [
          SkillRoadmapStep(stepNumber: 1, title: 'HTML/CSS', description: 'Web structure, modern CSS flexbox/grid layout, responsive design, and accessibility.', resource: 'Suggested: freeCodeCamp Responsive Web Design'),
          SkillRoadmapStep(stepNumber: 2, title: 'JavaScript', description: 'Core JS ES6+, async/await, DOM manipulation, and fetch API.', resource: 'Suggested: JavaScript.info & Eloquent JavaScript'),
          SkillRoadmapStep(stepNumber: 3, title: 'Frontend Framework', description: 'Master React, Flutter, or Vue for component-driven interactive interfaces.', resource: 'Suggested: React Official Documentation & Scrimba'),
          SkillRoadmapStep(stepNumber: 4, title: 'Backend Basics', description: 'Server creation and middleware logic with Node.js, Express, or Python.', resource: 'Suggested: Node.js & Express Crash Course'),
          SkillRoadmapStep(stepNumber: 5, title: 'Databases', description: 'Relational (PostgreSQL/SQL) and NoSQL (MongoDB) data modeling.', resource: 'Suggested: MongoDB University & PostgreSQL Tutorial'),
          SkillRoadmapStep(stepNumber: 6, title: 'REST APIs', description: 'Designing, building, testing, and securing RESTful web APIs and auth.', resource: 'Suggested: Postman API Fundamentals Student Expert'),
          SkillRoadmapStep(stepNumber: 7, title: 'Deployment & Git', description: 'Version control with Git/GitHub, CI/CD, and hosting on Vercel or Render.', resource: 'Suggested: Git & GitHub Interactive Guide'),
          SkillRoadmapStep(stepNumber: 8, title: 'Projects', description: 'Build 2-3 full stack web or mobile applications with user authentication.', resource: 'Suggested: Full Stack E-commerce or Social App on GitHub'),
          SkillRoadmapStep(stepNumber: 9, title: 'Interview Preparation', description: 'Data structures, algorithm practice on LeetCode, and system design basics.', resource: 'Suggested: NeetCode 150 & System Design Primer'),
        ],
      ),
      SkillRoadmapModel(
        id: 'ui_ux_designer',
        role: 'UI/UX Designer',
        aliases: ['ui/ux', 'ux designer', 'ui designer', 'product designer', 'design', 'ux design'],
        description: 'Craft intuitive user experiences, beautiful visual interfaces, and design systems.',
        steps: [
          SkillRoadmapStep(stepNumber: 1, title: 'Design Fundamentals', description: 'Color theory, typography, visual hierarchy, grid systems, and layout principles.', resource: 'Suggested: Refactoring UI & Interaction Design Foundation'),
          SkillRoadmapStep(stepNumber: 2, title: 'Figma', description: 'Master Figma tools, auto-layout, variants, components, and design tokens.', resource: 'Suggested: Figma Official YouTube Tutorials'),
          SkillRoadmapStep(stepNumber: 3, title: 'Wireframing', description: 'Low-fidelity wireframes, user flow mapping, and information architecture.', resource: 'Suggested: Balsamiq & Figma Wireframe Kits'),
          SkillRoadmapStep(stepNumber: 4, title: 'Prototyping', description: 'Interactive prototypes, micro-animations, and transition flows.', resource: 'Suggested: Figma Advanced Prototyping Workshop'),
          SkillRoadmapStep(stepNumber: 5, title: 'User Research Basics', description: 'User personas, interviews, usability testing, and journey mapping.', resource: 'Suggested: NN/g UX Research Methodologies'),
          SkillRoadmapStep(stepNumber: 6, title: 'Design Systems', description: 'Building component libraries, documentation, and design tokens.', resource: 'Suggested: Material Design 3 & Apple HIG Guidelines'),
          SkillRoadmapStep(stepNumber: 7, title: 'Portfolio Projects', description: 'Build 2 comprehensive end-to-end UX case studies.', resource: 'Suggested: Publish Case Studies on Behance or Notion'),
          SkillRoadmapStep(stepNumber: 8, title: 'Interview Preparation', description: 'Design challenge walkthroughs, whiteboard exercises, and portfolio presentation.', resource: 'Suggested: Articulating Design Decisions Practice'),
        ],
      ),
      SkillRoadmapModel(
        id: 'digital_marketer',
        role: 'Digital Marketer',
        aliases: ['digital marketer', 'marketing', 'digital marketing', 'seo specialist', 'growth marketer'],
        description: 'Drive customer acquisition, SEO, social strategy, and performance marketing.',
        steps: [
          SkillRoadmapStep(stepNumber: 1, title: 'Marketing Fundamentals', description: 'Target audience segmentation, brand positioning, and conversion funnels.', resource: 'Suggested: HubSpot Digital Marketing Certification'),
          SkillRoadmapStep(stepNumber: 2, title: 'Content Creation', description: 'Persuasive copywriting, visual graphics, and video scripting.', resource: 'Suggested: Copywriting Course & Canva Masterclass'),
          SkillRoadmapStep(stepNumber: 3, title: 'SEO & SEM', description: 'Keyword research, on-page SEO, Google Search Console, and Google Ads.', resource: 'Suggested: Google Search Ads Certification'),
          SkillRoadmapStep(stepNumber: 4, title: 'Social Media Marketing', description: 'Content calendars and organic strategy for LinkedIn, Instagram, and X.', resource: 'Suggested: Meta Social Media Marketing Certificate'),
          SkillRoadmapStep(stepNumber: 5, title: 'Analytics & Reporting', description: 'Google Analytics 4 (GA4), tracking conversions, and A/B testing.', resource: 'Suggested: Google Analytics 4 Skillshop Certification'),
          SkillRoadmapStep(stepNumber: 6, title: 'Email Marketing', description: 'Lead magnet creation, automated email drips, and newsletter campaigns.', resource: 'Suggested: Mailchimp or ConvertKit Academy'),
          SkillRoadmapStep(stepNumber: 7, title: 'Portfolio & Strategy', description: 'Execute a live marketing campaign and compile performance metrics.', resource: 'Suggested: Campaign Performance Case Study PDF'),
          SkillRoadmapStep(stepNumber: 8, title: 'Interview Preparation', description: 'Pitching marketing strategy decks and explaining ROI metrics.', resource: 'Suggested: Growth Marketing Interview Case Prep'),
        ],
      ),
      SkillRoadmapModel(
        id: 'product_manager',
        role: 'Product Manager',
        aliases: ['product manager', 'pm', 'product management', 'product owner'],
        description: 'Lead product vision, feature prioritization, agile execution, and cross-functional teams.',
        steps: [
          SkillRoadmapStep(stepNumber: 1, title: 'Product Fundamentals', description: 'Product lifecycle, vision, roadmap planning, and value propositions.', resource: 'Suggested: Inspired by Marty Cagan'),
          SkillRoadmapStep(stepNumber: 2, title: 'User Research', description: 'Customer discovery interviews, surveys, and problem validation.', resource: 'Suggested: The Mom Test by Rob Fitzpatrick'),
          SkillRoadmapStep(stepNumber: 3, title: 'Agile & Scrum', description: 'Sprint planning, writing user stories, and managing backlogs in Jira.', resource: 'Suggested: Professional Scrum Product Owner (PSPO)'),
          SkillRoadmapStep(stepNumber: 4, title: 'Data & Metrics', description: 'Tracking North Star metrics, retention funnels, and SQL analytics.', resource: 'Suggested: Amplitude & Mixpanel Analytics Academy'),
          SkillRoadmapStep(stepNumber: 5, title: 'Spec Writing & Wireframing', description: 'Writing Product Requirement Documents (PRDs) and sketching flows.', resource: 'Suggested: PRD Templates & Balsamiq'),
          SkillRoadmapStep(stepNumber: 6, title: 'Go-To-Market Strategy', description: 'Product launch strategies, feature positioning, and release notes.', resource: 'Suggested: Product-Led Growth Playbook'),
          SkillRoadmapStep(stepNumber: 7, title: 'Case Studies & Portfolio', description: 'Create 2 detailed product teardowns or PRD case studies.', resource: 'Suggested: Publish PRD teardown on Medium or Substack'),
          SkillRoadmapStep(stepNumber: 8, title: 'Interview Preparation', description: 'Product sense questions, estimation, and execution metrics interviews.', resource: 'Suggested: Cracking the PM Interview & Exponent'),
        ],
      ),
    ];
  }

  void _updateActiveSteps(SkillRoadmapModel roadmap) {
    _activeSteps = roadmap.steps.map((step) {
      final stepTitle = step.title.toLowerCase();
      final isAutoMatched = _userProfileSkills.any((userSkill) {
        final uSkillLower = userSkill.toLowerCase();
        return stepTitle.contains(uSkillLower) || uSkillLower.contains(stepTitle);
      });

      return SkillStepState(
        stepNumber: step.stepNumber,
        title: step.title,
        description: step.description,
        resource: step.resource,
        isCompleted: isAutoMatched,
      );
    }).toList();
  }

  void _onGoalChanged(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (_allRoadmaps.isEmpty) return;

    if (cleanQuery.isEmpty) {
      setState(() {
        _isFallback = false;
        _fallbackQuery = '';
        _activeRoadmap = _allRoadmaps.first;
        _updateActiveSteps(_allRoadmaps.first);
      });
      return;
    }

    SkillRoadmapModel? matched;

    for (final tmpl in _allRoadmaps) {
      if (tmpl.role.toLowerCase() == cleanQuery ||
          tmpl.aliases.contains(cleanQuery)) {
        matched = tmpl;
        break;
      }
    }

    if (matched == null) {
      for (final tmpl in _allRoadmaps) {
        if (tmpl.role.toLowerCase().contains(cleanQuery) ||
            cleanQuery.contains(tmpl.role.toLowerCase()) ||
            tmpl.aliases.any((alias) =>
                alias.contains(cleanQuery) || cleanQuery.contains(alias))) {
          matched = tmpl;
          break;
        }
      }
    }

    if (matched == null) {
      final queryWords = cleanQuery.split(RegExp(r'\s+'));
      int maxScore = 0;
      for (final tmpl in _allRoadmaps) {
        int score = 0;
        final roleLower = tmpl.role.toLowerCase();
        for (final word in queryWords) {
          if (word.length >= 3 &&
              (roleLower.contains(word) ||
                  tmpl.aliases.any((a) => a.contains(word)))) {
            score++;
          }
        }
        if (score > maxScore) {
          maxScore = score;
          matched = tmpl;
        }
      }
    }

    if (matched != null) {
      setState(() {
        _isFallback = false;
        _fallbackQuery = '';
        _activeRoadmap = matched;
        _updateActiveSteps(matched!);
      });
    } else {
      setState(() {
        _isFallback = true;
        _fallbackQuery = query.trim();
        _activeRoadmap = _allRoadmaps.first;
        _updateActiveSteps(_allRoadmaps.first);
      });
    }
  }

  void _selectRoleChip(SkillRoadmapModel tmpl) {
    _goalController.text = tmpl.role;
    _onGoalChanged(tmpl.role);
  }

  int get _completedCount => _activeSteps.where((step) => step.isCompleted).length;
  double get _progressPercentage =>
      _activeSteps.isEmpty ? 0.0 : _completedCount / _activeSteps.length;

  void _toggleStep(int index) {
    setState(() {
      _activeSteps[index].isCompleted = !_activeSteps[index].isCompleted;
    });
  }

  String get _encouragingText {
    if (_activeSteps.isNotEmpty && _completedCount == _activeSteps.length) {
      return '🎉 Roadmap complete! Great work.';
    } else if (_completedCount == 0) {
      return 'Start your journey today — take the first step!';
    } else {
      return "You're $_completedCount of ${_activeSteps.length} steps in — keep going!";
    }
  }

  PreferredSizeWidget _buildAppBar(AppThemeColors colors) {
    return AppBar(
      backgroundColor: colors.appBarBackground,
      elevation: 0,
      foregroundColor: Colors.white,
      title: const Text(
        'Skill Roadmap',
        style: TextStyle(
          fontFamily: 'Be Vietnam Pro',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, themeMode, _) {
        final colors = ThemeService.instance.colors;

        if (_isLoading) {
          return Scaffold(
            backgroundColor: colors.scaffoldBackground,
            appBar: _buildAppBar(colors),
            body: Center(
              child: CircularProgressIndicator(
                color: colors.primaryPurple,
              ),
            ),
          );
        }

        final int percentInt = (_progressPercentage * 100).round();
        final bool isAllCompleted =
            _activeSteps.isNotEmpty && _completedCount == _activeSteps.length;

        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: _buildAppBar(colors),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Goal Selection Section ("What's your goal?")
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.borderColor),
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
                      children: [
                        Text(
                          "What's your goal?",
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Type or select a career path to personalize your roadmap.',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 13,
                            color: colors.subtitleText,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _goalController,
                          onChanged: _onGoalChanged,
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 14,
                            color: colors.primaryText,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Data Analyst, Full Stack Developer...',
                            hintStyle: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 14,
                              color: colors.subtitleText,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: colors.primaryPurple,
                            ),
                            suffixIcon: _goalController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    color: colors.subtitleText,
                                    onPressed: () {
                                      _goalController.clear();
                                      _onGoalChanged('');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: colors.inputFillColor,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colors.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: colors.primaryPurple,
                                  width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _allRoadmaps.map((tmpl) {
                              final isSelected = !_isFallback &&
                                  _activeRoadmap?.id == tmpl.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () => _selectRoleChip(tmpl),
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colors.primaryPurple
                                          : colors.chipBackground,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.primaryPurple
                                            : colors.borderColor,
                                      ),
                                    ),
                                    child: Text(
                                      tmpl.role,
                                      style: TextStyle(
                                        fontFamily: 'Be Vietnam Pro',
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : colors.primaryPurple,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fallback Message Banner if query did not match
                  if (_isFallback) ...[
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.chipBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: colors.primaryPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "We don't have a roadmap for '$_fallbackQuery' yet — showing a general ${_activeRoadmap?.role ?? 'Data Analyst'} roadmap to get started.",
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 13,
                                height: 1.3,
                                color: colors.primaryPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 2. Progress Overview Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.borderColor),
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_activeRoadmap?.role ?? 'Career'} Progress',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.primaryText,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.chipBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$percentInt%',
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _encouragingText,
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 14,
                            fontWeight:
                                isAllCompleted ? FontWeight.bold : FontWeight.w600,
                            color: isAllCompleted
                                ? AppColors.accentOrange
                                : colors.subtitleText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _progressPercentage,
                            minHeight: 10,
                            backgroundColor: colors.borderColor,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Roadmap Timeline Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_activeRoadmap?.role ?? 'Skill'} Roadmap',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.primaryText,
                        ),
                      ),
                      Text(
                        '${_activeSteps.length} Steps',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.subtitleText,
                        ),
                      ),
                    ],
                  ),
                  if (_activeRoadmap?.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _activeRoadmap!.description,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 13,
                        color: colors.subtitleText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // 4. Timeline List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _activeSteps.length,
                    itemBuilder: (context, index) {
                      final step = _activeSteps[index];
                      final isLast = index == _activeSteps.length - 1;

                      return _RoadmapStepTile(
                        step: step,
                        isLast: isLast,
                        colors: colors,
                        onToggle: () => _toggleStep(index),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoadmapStepTile extends StatelessWidget {
  const _RoadmapStepTile({
    required this.step,
    required this.isLast,
    required this.colors,
    required this.onToggle,
  });

  final SkillStepState step;
  final bool isLast;
  final AppThemeColors colors;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline node + connecting line
          Column(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: step.isCompleted
                        ? AppColors.accentOrange
                        : colors.chipBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.isCompleted
                          ? AppColors.accentOrange
                          : colors.primaryPurple.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: step.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '${step.stepNumber}',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.primaryPurple,
                            ),
                          ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: step.isCompleted
                        ? AppColors.accentOrange
                        : colors.borderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content Card
          Expanded(
            child: GestureDetector(
              onTap: onToggle,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: step.isCompleted
                        ? AppColors.accentOrange.withValues(alpha: 0.5)
                        : colors.borderColor,
                  ),
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
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.title,
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primaryText,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: step.isCompleted
                                ? AppColors.accentOrange
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: step.isCompleted
                                  ? AppColors.accentOrange
                                  : colors.borderColor,
                              width: 2,
                            ),
                          ),
                          child: step.isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 13,
                        height: 1.4,
                        color: colors.subtitleText,
                      ),
                    ),
                    if (step.resource.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 14,
                            color: colors.primaryPurple,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              step.resource,
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colors.primaryPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
