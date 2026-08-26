import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, listEquals;
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/resume_text_extractor.dart';
import '../services/theme_service.dart';
import '../widgets/user_avatar_widget.dart';
import 'home_screen.dart';
import 'resume_analysis_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _successColor = Color(0xFF2FA84F);

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _preferredLocationController = TextEditingController();
  final TextEditingController _careerGoalsController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();

  int _selectedIndex = 2;
  String _selectedYear = '3rd Year';
  final List<String> _skills = ['Data Analysis', 'Python', 'UX Design'];

  String? _resumePath;
  String? _photoPath;
  Uint8List? _photoBytes;
  String? _fullName;

  static const List<String> _yearOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduated / Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _degreeController.dispose();
    _collegeController.dispose();
    _preferredLocationController.dispose();
    _careerGoalsController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final newSkill = _skillInputController.text.trim();
    if (newSkill.isEmpty) return;
    if (_skills.any((s) => s.toLowerCase() == newSkill.toLowerCase())) {
      _skillInputController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Skill "$newSkill" is already added')),
      );
      return;
    }
    setState(() {
      _skills.add(newSkill);
      _skillInputController.clear();
    });
  }

  TextStyle get _sectionStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ThemeService.instance.colors.primaryText,
      );

  TextStyle get _fieldStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 15,
        color: ThemeService.instance.colors.primaryText,
      );

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    required AppThemeColors colors,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 15,
        color: colors.subtitleText,
      ),
      prefixIcon: Icon(icon, color: colors.primaryPurple),
      filled: true,
      fillColor: colors.inputFillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primaryPurple, width: 1.4),
      ),
    );
  }

  Widget _buildAvatarWidget(Color primaryColor, Color iconBgColor) {
    return UserAvatarWidget(
      photoPath: _photoPath,
      photoBytes: _photoBytes,
      size: 106,
      iconSize: 36,
      primaryColor: primaryColor,
      iconBgColor: iconBgColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, _) {
        final colors = ThemeService.instance.colors;
        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: colors.appBarBackground,
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
                              color: colors.borderColor,
                              width: 4,
                            ),
                            color: colors.surfaceCard,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x10000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildAvatarWidget(colors.primaryPurple, colors.chipBackground),
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
                                color: colors.primaryText,
                              ),
                            ),
                          ),
                        if ((_photoPath != null && _photoPath!.isNotEmpty) || _photoBytes != null)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
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
                              final bytes = await file.readAsBytes();
                              if (bytes.lengthInBytes > 5 * 1024 * 1024) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image file too large. Maximum size is 5MB.')),
                                );
                                return;
                              }
                              try {
                                final userId = AuthService.instance.currentUserId;
                                if (userId == null) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to update your profile')));
                                  return;
                                }
                                String photoPathToSave;
                                if (kIsWeb) {
                                  final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'png';
                                  final mimeType = (ext == 'jpg' || ext == 'jpeg') ? 'image/jpeg' : 'image/png';
                                  final base64Str = base64Encode(bytes);
                                  photoPathToSave = 'data:$mimeType;base64,$base64Str';
                                } else {
                                  photoPathToSave = file.path ?? file.name;
                                }
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
                                    backgroundColor: colors.primaryPurple,
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
                                    backgroundColor: colors.primaryPurple,
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
                  _FieldGroup(
                    label: 'Full Name',
                    labelColor: colors.primaryText,
                    child: TextField(
                      controller: _fullNameController,
                      style: _fieldStyle,
                      decoration: _inputDecoration(
                        hintText: 'Enter your full name',
                        icon: Icons.person_outline,
                        colors: colors,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldGroup(
                    label: 'Education/Degree',
                    labelColor: colors.primaryText,
                    child: TextField(
                      controller: _degreeController,
                      style: _fieldStyle,
                      decoration: _inputDecoration(
                        hintText: 'e.g. BSc Computer Science',
                        icon: Icons.school_outlined,
                        colors: colors,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldGroup(
                    label: 'College/Institution',
                    labelColor: colors.primaryText,
                    child: TextField(
                      controller: _collegeController,
                      style: _fieldStyle,
                      decoration: _inputDecoration(
                        hintText: 'Enter college or institution',
                        icon: Icons.account_balance_outlined,
                        colors: colors,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldGroup(
                    label: 'Year of Study',
                    labelColor: colors.primaryText,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedYear,
                      style: _fieldStyle,
                      dropdownColor: colors.surfaceCard,
                      iconEnabledColor: colors.primaryPurple,
                      decoration: _inputDecoration(
                        hintText: 'Select year',
                        icon: Icons.calendar_today_outlined,
                        colors: colors,
                      ),
                      items: _yearOptions
                          .map(
                            (year) => DropdownMenuItem<String>(
                              value: year,
                              child: Text(
                                year,
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontFamilyFallback: const ['sans-serif'],
                                  fontSize: 15,
                                  color: colors.primaryText,
                                ),
                              ),
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
                    labelColor: colors.primaryText,
                    child: TextField(
                      controller: _preferredLocationController,
                      style: _fieldStyle,
                      decoration: _inputDecoration(
                        hintText: 'Enter preferred location',
                        icon: Icons.location_on_outlined,
                        colors: colors,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldGroup(
                    label: 'Key Skills',
                    labelColor: colors.primaryText,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _skillInputController,
                                style: _fieldStyle,
                                onSubmitted: (_) => _addSkill(),
                                decoration: _inputDecoration(
                                  hintText: 'Add a new skill (e.g. Flutter, SQL)',
                                  icon: Icons.code_rounded,
                                  colors: colors,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _addSkill,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primaryPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.borderColor),
                          ),
                          child: _skills.isEmpty
                              ? Text(
                                  'No skills added yet. Type a skill above and tap Add.',
                                  style: TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontFamilyFallback: const ['sans-serif'],
                                    fontSize: 13,
                                    color: colors.subtitleText,
                                  ),
                                )
                              : Wrap(
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
                                            color: colors.chipBackground,
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: colors.borderColor),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                skill,
                                                style: TextStyle(
                                                  fontFamily: 'Be Vietnam Pro',
                                                  fontFamilyFallback: const ['sans-serif'],
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: colors.primaryPurple,
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
                                                  color: colors.primaryPurple,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldGroup(
                    label: 'Career Goals',
                    labelColor: colors.primaryText,
                    child: TextField(
                      controller: _careerGoalsController,
                      style: _fieldStyle,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        hintText: 'Describe your career goals',
                        icon: Icons.flag_outlined,
                        colors: colors,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Resume / CV', style: _sectionStyle),
                  const SizedBox(height: 12),
                  _UploadArea(
                    colors: colors,
                    onChooseFile: () async {
                      try {
                        final result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'doc', 'docx'],
                        );
                        if (result.isEmpty) return;
                        final file = result.first;
                        final bytes = await file.readAsBytes();

                        final userId = AuthService.instance.currentUserId;
                        if (userId == null) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to upload your resume')));
                          return;
                        }
                        final resumePathToSave = file.path ?? file.name;

                        final extraction = await ResumeTextExtractor.extract(bytes, file.name);

                        await DbService.instance.updateUserById(userId, {
                          'resume_path': resumePathToSave,
                          'resume_text': extraction.text,
                        });

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
                            backgroundColor: colors.primaryPurple,
                            content: Text(snackMessage, style: const TextStyle(color: Colors.white)),
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
                            backgroundColor: colors.primaryPurple,
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
                        color: colors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.borderColor),
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
                          await _loadUser();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile saved')),
                          );
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context, true);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          }
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
              if (index == 2) return;
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, true);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                }
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

  Future<void> _loadUser() async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) return;
    final user = await DbService.instance.getUserById(userId);
    if (user == null) return;
    if (!mounted) return;

    final storedSkills = (user['skills'] as String?) ?? '';
    final parsedSkills = storedSkills.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    final newName = user['name'] as String?;
    final newResume = user['resume_path'] as String?;
    final newPhoto = user['photo_path'] as String?;
    final newYear = (user['year_of_study'] as String?) ?? _selectedYear;
    final newDegree = (user['degree'] as String?) ?? '';
    final newCollege = (user['college'] as String?) ?? '';
    final newLoc = (user['preferred_location'] as String?) ?? '';
    final newGoals = (user['career_goals'] as String?) ?? '';

    if (_fullNameController.text != (newName ?? '')) _fullNameController.text = newName ?? '';
    if (_degreeController.text != newDegree) _degreeController.text = newDegree;
    if (_collegeController.text != newCollege) _collegeController.text = newCollege;
    if (_preferredLocationController.text != newLoc) _preferredLocationController.text = newLoc;
    if (_careerGoalsController.text != newGoals) _careerGoalsController.text = newGoals;

    if (!listEquals(_skills, parsedSkills) && parsedSkills.isNotEmpty) {
      _skills
        ..clear()
        ..addAll(parsedSkills);
    }

    if (_fullName != newName ||
        _resumePath != newResume ||
        _photoPath != newPhoto ||
        _selectedYear != newYear) {
      setState(() {
        _fullName = newName;
        _resumePath = newResume;
        _photoPath = newPhoto;
        _selectedYear = newYear;
      });
    }
  }
}

class _FieldGroup extends StatelessWidget {
  const _FieldGroup({
    required this.label,
    required this.child,
    required this.labelColor,
  });

  final String label;
  final Widget child;
  final Color labelColor;

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
            color: labelColor,
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
    required this.colors,
    required this.onChooseFile,
  });

  final AppThemeColors colors;
  final VoidCallback onChooseFile;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: colors.borderColor,
        radius: 12,
        strokeWidth: 1.3,
        dashWidth: 8,
        dashGap: 6,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.chipBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.upload_file_outlined,
                color: colors.primaryPurple,
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
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Drag & drop or browse your files. Max 5MB.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: const ['sans-serif'],
                fontSize: 13,
                color: colors.subtitleText,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: TextButton(
                onPressed: onChooseFile,
                style: TextButton.styleFrom(
                  backgroundColor: colors.primaryPurple,
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