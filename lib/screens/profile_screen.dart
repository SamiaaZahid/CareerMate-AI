import 'dart:math' as math;
import '../services/auth_service.dart';

import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'resume_analysis_screen.dart';
import 'settings_screen.dart';
import '../constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import '../services/db_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _backgroundColor = Color(0xFFF5F5F7);
  static const Color _primaryColor = Color(0xFF54309C);
  static const Color _borderColor = Color(0xFFE8E1F5);
  static const Color _inactiveColor = Color(0xFF8B8B98);
  static const Color _successColor = Color(0xFF2FA84F);

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _preferredLocationController = TextEditingController();
  final TextEditingController _careerGoalsController = TextEditingController();

  int _selectedIndex = 2;
  String _selectedYear = '3rd Year';
  final List<String> _skills = ['Data Analysis', 'Python', 'UX Design'];
  String? _resumePath;
  String? _photoPath;
  String? _fullName;
  final List<String> _yearOptions = const [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduate',
  ];

  

  TextStyle get _sectionStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F1F28),
      );

  

  TextStyle get _fieldStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 15,
        color: Color(0xFF1F1F28),
      );
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
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
                child: Column(
                  children: [
                    Container(
                      width: 114,
                      height: 114,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE8E1F5),
                          width: 4,
                        ),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF2EDFC),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 36,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_fullName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _fullName!,
                          style: const TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontFamilyFallback: ['sans-serif'],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1F28),
                          ),
                        ),
                      ),
                    if (_photoPath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Photo saved',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontFamilyFallback: ['sans-serif'],
                            fontSize: 12,
                            color: _successColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png'],
                          );
                          if (result.isEmpty) return;
                          final file = result.first;
                          try {
                            final userId = AuthService.instance.currentUserId;
                            if (userId == null) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to update your profile')));
                              return;
                            }
                            await DbService.instance.updateUserById(userId, {'photo_path': file.path});
                            if (!context.mounted) return;
                            final messenger = ScaffoldMessenger.of(context);
                            final double snackLeft = MediaQuery.of(context).size.width * 0.5;
                            messenger.showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(left: snackLeft, bottom: 16, right: 16),
                                backgroundColor: AppColors.primaryPurple,
                                content: Text('Profile photo updated: ${file.name}', style: const TextStyle(color: Colors.white)),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            final messenger = ScaffoldMessenger.of(context);
                            final double snackLeft = MediaQuery.of(context).size.width * 0.5;
                            messenger.showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(left: snackLeft, bottom: 16, right: 16),
                                backgroundColor: AppColors.primaryPurple,
                                content: Text('Failed to save photo: $e', style: const TextStyle(color: Colors.white)),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Edit Photo',
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
                    const SizedBox(height: 24),
                    // Load user data on first build
                    FutureBuilder(
                      future: _loadUser(),
                      builder: (context, snapshot) {
                        return const SizedBox.shrink();
                      },
                    ),
              _FieldGroup(
                label: 'Full Name',
                child: TextField(
                  controller: _fullNameController,
                  style: _fieldStyle,
                  decoration: _inputDecoration(
                    hintText: 'Enter your full name',
                    icon: Icons.person_outline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FieldGroup(
                label: 'Education/Degree',
                child: TextField(
                  controller: _degreeController,
                  style: _fieldStyle,
                  decoration: _inputDecoration(
                    hintText: 'e.g. BSc Computer Science',
                    icon: Icons.school_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FieldGroup(
                label: 'College/Institution',
                child: TextField(
                  controller: _collegeController,
                  style: _fieldStyle,
                  decoration: _inputDecoration(
                    hintText: 'Enter college or institution',
                    icon: Icons.account_balance_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FieldGroup(
                label: 'Year of Study',
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedYear,
                  style: _fieldStyle,
                  iconEnabledColor: _primaryColor,
                  decoration: _inputDecoration(
                    hintText: 'Select year',
                    icon: Icons.calendar_today_outlined,
                  ),
                  items: _yearOptions
                      .map(
                        (year) => DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              _FieldGroup(
                label: 'Preferred Location',
                child: TextField(
                  controller: _preferredLocationController,
                  style: _fieldStyle,
                  decoration: _inputDecoration(
                    hintText: 'Enter preferred location',
                    icon: Icons.location_on_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FieldGroup(
                label: 'Key Skills',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD8D8E3)),
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _skills
                        .map(
                          (skill) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2EDFC),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$skill ×',
                                  style: const TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontFamilyFallback: ['sans-serif'],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _skills.remove(skill);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: _primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FieldGroup(
                label: 'Career Goals',
                child: TextField(
                  controller: _careerGoalsController,
                  style: _fieldStyle,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    hintText: 'Describe your career goals',
                    icon: Icons.flag_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Resume / CV', style: _sectionStyle),
              const SizedBox(height: 12),
              _UploadArea(
                primaryColor: AppColors.accentOrange,
                onChooseFile: () async {
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx'],
                  );
                  if (result.isEmpty) return;
                  final file = result.first;
                  // save path to DB (example: upsert user with resume_path)
                  try {
                    final userId = AuthService.instance.currentUserId;
                    if (userId == null) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to upload your resume')));
                      return;
                    }
                    await DbService.instance.updateUserById(userId, {'resume_path': file.path});
                    if (!context.mounted) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final double snackLeft = MediaQuery.of(context).size.width * 0.5;
                    messenger.showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(left: snackLeft, bottom: 16, right: 16),
                        backgroundColor: AppColors.primaryPurple,
                        content: Text('Uploaded: ${file.name}', style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final double snackLeft = MediaQuery.of(context).size.width * 0.5;
                    messenger.showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(left: snackLeft, bottom: 16, right: 16),
                        backgroundColor: AppColors.primaryPurple,
                        content: Text('Failed to save file: $e', style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD8F0DD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: _successColor,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'resume.pdf uploaded',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontFamilyFallback: ['sans-serif'],
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _resumePath != null ? 1 : 0,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE4F5E8),
                        valueColor: AlwaysStoppedAnimation<Color>(_successColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final userId = AuthService.instance.currentUserId;
                    if (userId == null) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in before saving your profile')),
                      );
                      return;
                    }

                    final payload = {
                      'name': _fullNameController.text.trim(),
                      'degree': _degreeController.text.trim(),
                      'college': _collegeController.text.trim(),
                      'year_of_study': _selectedYear,
                      'preferred_location': _preferredLocationController.text.trim(),
                      'skills': _skills.join(', '),
                      'career_goals': _careerGoalsController.text.trim(),
                    };

                    final updated = await DbService.instance.updateUserById(userId, payload);
                    if (!context.mounted) return;
                    if (updated > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile saved')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Unable to save profile')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    'Save Profile',
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
        backgroundColor: Colors.white,
        selectedItemColor: _primaryColor,
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
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ResumeAnalysisScreen(),
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

  Future<void> _loadUser() async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) return;
    final user = await DbService.instance.getUserById(userId);
    if (user == null) return;
    if (!mounted) return;

    final storedSkills = (user['skills'] as String?) ?? '';
    final parsedSkills = storedSkills.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    setState(() {
      _fullName = user['name'] as String?;
      _resumePath = user['resume_path'] as String?;
      _photoPath = user['photo_path'] as String?;
      _selectedYear = (user['year_of_study'] as String?) ?? _selectedYear;
      _fullNameController.text = _fullName ?? '';
      _degreeController.text = (user['degree'] as String?) ?? '';
      _collegeController.text = (user['college'] as String?) ?? '';
      _preferredLocationController.text = (user['preferred_location'] as String?) ?? '';
      _careerGoalsController.text = (user['career_goals'] as String?) ?? '';
      if (parsedSkills.isNotEmpty) {
        _skills
          ..clear()
          ..addAll(parsedSkills);
      }
    });
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 15,
        color: Color(0xFF9A9AA6),
      ),
      prefixIcon: Icon(icon, color: _primaryColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8D8E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 1.4),
      ),
    );
  }
}

class _FieldGroup extends StatelessWidget {
  const _FieldGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontFamilyFallback: ['sans-serif'],
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F28),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _UploadArea extends StatelessWidget {
  const _UploadArea({
    required this.primaryColor,
    required this.onChooseFile,
  });

  final Color primaryColor;
  final VoidCallback onChooseFile;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFBFAEE6),
        radius: 12,
        strokeWidth: 1.3,
        dashWidth: 8,
        dashGap: 6,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EDFC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.upload_file_outlined,
                color: primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload your CV (PDF)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: ['sans-serif'],
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F28),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Drag & drop or browse your files. Max 5MB.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: ['sans-serif'],
                fontSize: 13,
                color: Color(0xFF6F6F7B),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: TextButton(
                onPressed: onChooseFile,
                style: TextButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'Choose File',
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
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashGap != oldDelegate.dashGap;
  }
}
