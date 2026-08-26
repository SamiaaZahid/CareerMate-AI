import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/resume_text_extractor.dart';
import 'home_screen.dart';
import 'resume_analysis_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  Uint8List? _photoBytes;
  String? _fullName;
  final List<String> _yearOptions = const [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduate',
  ];

  TextStyle get _sectionStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  TextStyle get _fieldStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 15,
        color: Theme.of(context).colorScheme.onSurface,
      );

  Widget _buildAvatarWidget(Color primaryColor, Color iconBgColor) {
    if (_photoBytes != null && _photoBytes!.isNotEmpty) {
      return ClipOval(
        child: Image.memory(
          _photoBytes!,
          key: ValueKey('bytes-${_photoBytes.hashCode}-${DateTime.now().millisecondsSinceEpoch}'),
          width: 106,
          height: 106,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatarIcon(primaryColor, iconBgColor),
        ),
      );
    }
    if (_photoPath != null && _photoPath!.isNotEmpty) {
      final photoPath = _photoPath!;
      final isNetwork = photoPath.startsWith('http://') || photoPath.startsWith('https://');
      final imageKey = ValueKey('$photoPath-${DateTime.now().millisecondsSinceEpoch}');

      if (isNetwork) {
        return ClipOval(
          child: Image.network(
            photoPath,
            key: imageKey,
            width: 106,
            height: 106,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatarIcon(primaryColor, iconBgColor),
          ),
        );
      } else if (!kIsWeb && File(photoPath).existsSync()) {
        return ClipOval(
          child: Image.file(
            File(photoPath),
            key: imageKey,
            width: 106,
            height: 106,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatarIcon(primaryColor, iconBgColor),
          ),
        );
      }
    }
    return _buildDefaultAvatarIcon(primaryColor, iconBgColor);
  }

  Widget _buildDefaultAvatarIcon(Color primaryColor, Color iconBgColor) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconBgColor,
        ),
        child: Icon(
          Icons.person,
          size: 36,
          color: primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF9D7BEE) : _primaryColor;
    final cardBg = Theme.of(context).cardColor;
    final iconBgColor = isDark ? const Color(0xFF2C2540) : const Color(0xFFF2EDFC);
    final borderColor = isDark ? const Color(0xFF2C2C35) : _borderColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : primaryColor,
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
                          color: borderColor,
                          width: 4,
                        ),
                        color: cardBg,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildAvatarWidget(primaryColor, iconBgColor),
                    ),
                    const SizedBox(height: 14),
                    if (_fullName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _fullName!,
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontFamilyFallback: const ['sans-serif'],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    if (_photoPath != null || _photoBytes != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Photo saved',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontFamilyFallback: const ['sans-serif'],
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
                          final bytes = await file.readAsBytes();
                          try {
                            final userId = AuthService.instance.currentUserId;
                            if (userId == null) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to update your profile')));
                              return;
                            }
                            final photoPathToSave = file.path ?? file.name;
                            await DbService.instance.updateUserById(userId, {'photo_path': photoPathToSave});
                            PaintingBinding.instance.imageCache.clear();
                            PaintingBinding.instance.imageCache.clearLiveImages();
                            if (!context.mounted) return;
                            setState(() {
                              _photoBytes = bytes;
                              _photoPath = photoPathToSave;
                            });
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
                    primaryColor: primaryColor,
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
                    primaryColor: primaryColor,
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
                    primaryColor: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FieldGroup(
                label: 'Year of Study',
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedYear,
                  style: _fieldStyle,
                  dropdownColor: cardBg,
                  iconEnabledColor: primaryColor,
                  decoration: _inputDecoration(
                    hintText: 'Select year',
                    icon: Icons.calendar_today_outlined,
                    primaryColor: primaryColor,
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
                    primaryColor: primaryColor,
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
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
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
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$skill ×',
                                  style: TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontFamilyFallback: const ['sans-serif'],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _skills.remove(skill);
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: primaryColor,
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
                    primaryColor: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Resume / CV', style: _sectionStyle),
              const SizedBox(height: 12),
              _UploadArea(
                primaryColor: AppColors.accentOrange,
                onChooseFile: () async {
                  try {
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx'],
                    );
                    if (result.isEmpty) return;
                    final file = result.first;
                    final bytes = await file.readAsBytes();
                    debugPrint('[ProfileScreen] CV picked: ${file.name}, bytes length: ${bytes.length}');

                    final userId = AuthService.instance.currentUserId;
                    debugPrint('[ProfileScreen] Current userId: $userId');
                    if (userId == null) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to upload your resume')));
                      return;
                    }
                    final resumePathToSave = file.path ?? file.name;
                    debugPrint('[ProfileScreen] Updating user $userId with resume_path: $resumePathToSave');

                    final extraction = await ResumeTextExtractor.extract(bytes, file.name);
                    debugPrint(
                      '[ProfileScreen] Extraction status: ${extraction.status}, text length: ${extraction.text.length}',
                    );

                    final updateResult = await DbService.instance.updateUserById(userId, {
                      'resume_path': resumePathToSave,
                      'resume_text': extraction.text,
                    });
                    debugPrint('[ProfileScreen] updateUserById result: $updateResult');

                    setState(() {
                      _resumePath = resumePathToSave;
                    });
                    if (!context.mounted) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final double snackLeft = MediaQuery.of(context).size.width * 0.5;

                    final String snackMessage;
                    switch (extraction.status) {
                      case ResumeExtractionStatus.success:
                        snackMessage = 'Uploaded: ${file.name}';
                        break;
                      case ResumeExtractionStatus.unsupportedFormat:
                        snackMessage = 'Uploaded, but .doc isn\'t supported for AI analysis — '
                            'please re-upload as PDF or DOCX to get a real resume score.';
                        break;
                      case ResumeExtractionStatus.tooShort:
                        snackMessage = 'Uploaded, but we couldn\'t read much text from this file — '
                            'if it\'s a scanned/image resume, try a text-based PDF instead.';
                        break;
                      case ResumeExtractionStatus.failed:
                        snackMessage = 'Uploaded, but something went wrong reading this file\'s content.';
                        break;
                    }

                    messenger.showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(left: snackLeft, bottom: 16, right: 16),
                        backgroundColor: AppColors.primaryPurple,
                        content: Text(snackMessage, style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  } catch (e, st) {
                    debugPrint('[ProfileScreen] Error uploading CV: $e\n$st');
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
              if (_resumePath != null && _resumePath!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD8F0DD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: _successColor,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_resumePath!.split(RegExp(r"[/\\]")).last} uploaded',
                              style: const TextStyle(
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
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          minHeight: 8,
                          backgroundColor: Color(0xFFE4F5E8),
                          valueColor: AlwaysStoppedAnimation<Color>(_successColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    required Color primaryColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 15,
        color: Color(0xFF9A9AA6),
      ),
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF2C2C35) : const Color(0xFFD8D8E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.4),
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
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontFamilyFallback: const ['sans-serif'],
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final iconBgColor = isDark ? const Color(0xFF2C2540) : const Color(0xFFF2EDFC);

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: isDark ? const Color(0xFF4A3E6B) : const Color(0xFFBFAEE6),
        radius: 12,
        strokeWidth: 1.3,
        dashWidth: 8,
        dashGap: 6,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.upload_file_outlined,
                color: primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your CV (PDF)',
              textAlign: TextAlign.center,
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