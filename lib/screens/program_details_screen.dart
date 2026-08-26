import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/recommendation_item.dart';
import '../services/theme_service.dart';

class ProgramDetailsScreen extends StatefulWidget {
  const ProgramDetailsScreen({super.key, required this.item});

  final RecommendationItemData item;

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  bool _hasApplied = false;

  @override
  Widget build(BuildContext context) {
    final bool isInternship = widget.item.type == RecommendationType.internship;

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
            title: Text(
              isInternship ? 'Internship Details' : 'Scholarship Details',
              style: const TextStyle(
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
                  _HeaderCard(
                    item: widget.item,
                    isInternship: isInternship,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'About this ${isInternship ? 'Internship' : 'Scholarship'}',
                    colors: colors,
                    child: Text(
                      widget.item.description,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontFamilyFallback: const ['sans-serif'],
                        fontSize: 14,
                        height: 1.5,
                        color: colors.subtitleText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Requirements',
                    colors: colors,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.item.requirements
                          .map(
                            (req) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                    color: colors.primaryPurple,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      req,
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
                          )
                          .toList(),
                    ),
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
                                    'Application submitted for "${widget.item.title}"!',
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
                                fontFamilyFallback: ['sans-serif'],
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
    required this.item,
    required this.isInternship,
    required this.colors,
  });

  final RecommendationItemData item;
  final bool isInternship;
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
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.chipBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isInternship ? Icons.work_outline : Icons.school_outlined,
                  size: 16,
                  color: colors.primaryPurple,
                ),
                const SizedBox(width: 6),
                Text(
                  isInternship ? 'Internship' : 'Scholarship',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontFamilyFallback: const ['sans-serif'],
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: const ['sans-serif'],
              fontSize: 20,
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
              fontSize: 14,
              color: colors.subtitleText,
            ),
          ),
          if (item.location != null || item.deadline != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (item.location != null)
                  _MetaChip(icon: Icons.location_on_outlined, label: item.location!, colors: colors),
                if (item.deadline != null)
                  _MetaChip(icon: Icons.event_outlined, label: item.deadline!, colors: colors),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colors.subtitleText),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontFamilyFallback: const ['sans-serif'],
            fontSize: 13,
            color: colors.subtitleText,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.colors,
  });

  final String title;
  final Widget child;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
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
              fontFamilyFallback: const ['sans-serif'],
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}