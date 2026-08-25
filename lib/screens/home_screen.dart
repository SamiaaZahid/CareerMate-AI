import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'program_listing_screen.dart';
import 'resume_analysis_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _profileName;
  bool _hasCvUploaded = false;
  String? _cvFileName;

  static const Color _primaryColor = Color(0xFF54309C);
  static const Color _borderColor = Color(0xFFE8E1F5);
  static const Color _inactiveColor = Color(0xFF8B8B98);

  TextStyle get _headlineStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  TextStyle get _sectionStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  TextStyle get _cardTitleStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _profileName = null;
          _hasCvUploaded = false;
          _cvFileName = null;
        });
      }
      return;
    }

    final user = await DbService.instance.getUserById(userId);
    final name = (user?['name'] as String?)?.trim();
    final resumePath = (user?['resume_path'] as String?)?.trim();
    final hasCv = resumePath != null && resumePath.isNotEmpty;
    final fileName = hasCv ? resumePath.split(RegExp(r'[/\\]')).last : null;

    debugPrint('[HomeScreen] _loadUserData -> userId: $userId, resume_path: $resumePath, hasCv: $hasCv');
    if (mounted) {
      setState(() {
        _profileName = name?.isNotEmpty == true ? name : null;
        _hasCvUploaded = hasCv;
        _cvFileName = fileName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFA582F7) : _primaryColor;
    final iconBgColor = isDark ? const Color(0xFF2C2640) : const Color(0xFFF2EDFC);
    final cardBorderColor = isDark ? const Color(0xFF2E2E3E) : _borderColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: const [
            Icon(Icons.auto_awesome_rounded, size: 22),
            SizedBox(width: 8),
            Text(
              'CareerMate AI',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: ['sans-serif'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
            tooltip: 'AI Assistant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0x33FFFFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profileName == null || _profileName!.trim().isEmpty
                    ? 'Welcome back!'
                    : 'Welcome back, $_profileName!',
                style: _headlineStyle,
              ),
              const SizedBox(height: 20),
              _StatusCard(
                title: 'Profile Completeness',
                titleStyle: _sectionStyle,
                borderColor: cardBorderColor,
                content: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _hasCvUploaded ? '80%' : '50%',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontFamilyFallback: const ['sans-serif'],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
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
                            _hasCvUploaded ? 'Great progress!' : 'Almost there',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontFamilyFallback: const ['sans-serif'],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFA0A0B2) : const Color(0xFF4C4C58),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: _hasCvUploaded ? 0.8 : 0.5,
                              minHeight: 8,
                              backgroundColor: isDark ? const Color(0xFF2C2C3A) : const Color(0xFFEDEAF7),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4A90E2),
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
                titleStyle: _sectionStyle,
                borderColor: cardBorderColor,
                content: Row(
                  children: [
                    Icon(
                      _hasCvUploaded ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                      color: _hasCvUploaded ? const Color(0xFF2FA84F) : AppColors.accentOrange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _hasCvUploaded
                            ? (_cvFileName != null ? 'CV uploaded: $_cvFileName' : 'CV uploaded successfully')
                            : 'No CV uploaded yet',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontFamilyFallback: const ['sans-serif'],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFA0A0B2) : const Color(0xFF4C4C58),
                        ),
                      ),
                    ),
                    if (!_hasCvUploaded)
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                          _loadUserData();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentOrange,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        child: const Text(
                          'Upload',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Explore Tools', style: _sectionStyle),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05,
                children: [
                  _ToolCard(
                    icon: Icons.description_outlined,
                    label: 'Resume Analysis',
                    labelStyle: _cardTitleStyle,
                    iconBgColor: iconBgColor,
                    borderColor: cardBorderColor,
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
                    icon: Icons.work_outline,
                    label: 'Internships',
                    labelStyle: _cardTitleStyle,
                    iconBgColor: iconBgColor,
                    borderColor: cardBorderColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProgramListingScreen(initialFilter: 'internships'),
                        ),
                      );
                    },
                  ),
                  _ToolCard(
                    icon: Icons.school_outlined,
                    label: 'Scholarships',
                    labelStyle: _cardTitleStyle,
                    iconBgColor: iconBgColor,
                    borderColor: cardBorderColor,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Scholarships coming soon'),
                        ),
                      );
                    },
                  ),
                  _ToolCard(
                    icon: Icons.trending_up_outlined,
                    label: 'Skill Roadmap',
                    labelStyle: _cardTitleStyle,
                    iconBgColor: iconBgColor,
                    borderColor: cardBorderColor,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Skill Roadmap coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text(
                    'AI Career Chat',
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: primaryColor,
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
        onTap: (index) async {
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
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.titleStyle,
    required this.borderColor,
    required this.content,
  });

  final String title;
  final TextStyle titleStyle;
  final Color borderColor;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.label,
    required this.labelStyle,
    required this.iconBgColor,
    required this.borderColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final TextStyle labelStyle;
  final Color iconBgColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(label, style: labelStyle),
            ],
          ),
        ),
      ),
    );
  }
}