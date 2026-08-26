import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'models/scholarship_model.dart';
import 'services/theme_service.dart';

class ScholarshipDetailsScreen extends StatefulWidget {
  const ScholarshipDetailsScreen({
    super.key,
    required this.scholarship,
  });

  final Scholarship scholarship;

  static const Color primaryPurple = Color(0xFF5B3FA8);
  static const Color gradientStart = Color(0xFF6B4FCB);
  static const Color lightLavender = Color(0xFFEDE7FA);

  @override
  State<ScholarshipDetailsScreen> createState() =>
      _ScholarshipDetailsScreenState();
}

class _ScholarshipDetailsScreenState extends State<ScholarshipDetailsScreen> {
  bool _hasApplied = false;

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'security':
        return Icons.security_rounded;
      default:
        return Icons.card_membership_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(widget.scholarship.icon);

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
              'Scholarship Details',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(
                    scholarship: widget.scholarship,
                    iconData: iconData,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Provider',
                    icon: Icons.business_rounded,
                    content: widget.scholarship.provider,
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Amount',
                    icon: Icons.monetization_on_outlined,
                    content: widget.scholarship.amount,
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Deadline',
                    icon: Icons.event_outlined,
                    content: widget.scholarship.deadline,
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Eligibility Criteria',
                    icon: Icons.verified_user_outlined,
                    content: widget.scholarship.eligibility,
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Description',
                    icon: Icons.description_outlined,
                    content: widget.scholarship.fullDescription,
                    colors: colors,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _hasApplied
                          ? null
                          : () {
                              setState(() {
                                _hasApplied = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: colors.primaryPurple,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'Application submitted for "${widget.scholarship.title}"!',
                                    style: const TextStyle(
                                      fontFamily: 'Be Vietnam Pro',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasApplied
                            ? colors.chipBackground
                            : AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: colors.chipBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _hasApplied
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Color(0xFF2FA84F), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Applied ✓',
                                  style: TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2FA84F),
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Apply Now',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.scholarship,
    required this.iconData,
    required this.colors,
  });

  final Scholarship scholarship;
  final IconData iconData;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: colors.primaryPurple,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scholarship.title,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scholarship.provider,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 14,
                        color: colors.subtitleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: colors.primaryPurple,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scholarship.amount,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 16,
                      color: colors.subtitleText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Deadline: ${scholarship.deadline}',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 13,
                        color: colors.subtitleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.content,
    required this.colors,
  });

  final String title;
  final IconData icon;
  final String content;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      width: double.infinity,
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
            children: [
              Icon(
                icon,
                size: 20,
                color: colors.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 14,
              height: 1.5,
              color: colors.subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}
