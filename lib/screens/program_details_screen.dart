import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/recommendation_item.dart';

const Color kDetailsPrimaryColor = AppColors.primaryPurple;
const Color kDetailsBackgroundColor = Color(0xFFF5F5F7);
const Color kDetailsBorderColor = Color(0xFFE8E1F5);

/// Displays full details for a single internship or scholarship
/// recommendation, reached by tapping "View" on the Resume Analysis
/// (program listing) screen.
class ProgramDetailsScreen extends StatelessWidget {
  const ProgramDetailsScreen({super.key, required this.item});

  final RecommendationItemData item;

  @override
  Widget build(BuildContext context) {
    final bool isInternship = item.type == RecommendationType.internship;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFA582F7) : kDetailsPrimaryColor;
    final cardBorder = isDark ? const Color(0xFF2E2E3E) : kDetailsBorderColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : kDetailsPrimaryColor,
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
                item: item,
                isInternship: isInternship,
                primaryColor: primaryColor,
                cardBorder: cardBorder,
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'About this ${isInternship ? 'Internship' : 'Scholarship'}',
                cardBorder: cardBorder,
                child: Text(
                  item.description,
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontFamilyFallback: const ['sans-serif'],
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? const Color(0xFFA0A0B2) : const Color(0xFF5F5F6B),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Requirements',
                cardBorder: cardBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.requirements
                      .map(
                        (req) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  req,
                                  style: TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontFamilyFallback: const ['sans-serif'],
                                    fontSize: 14,
                                    color: isDark ? const Color(0xFFA0A0B2) : const Color(0xFF5F5F6B),
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
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Application flow for "${item.title}" coming soon'),
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
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.item,
    required this.isInternship,
    required this.primaryColor,
    required this.cardBorder,
  });

  final RecommendationItemData item;
  final bool isInternship;
  final Color primaryColor;
  final Color cardBorder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBg = isDark ? const Color(0xFF2C2640) : const Color(0xFFF2EDFC);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
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
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isInternship ? Icons.work_outline : Icons.school_outlined,
                  size: 16,
                  color: primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  isInternship ? 'Internship' : 'Scholarship',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontFamilyFallback: const ['sans-serif'],
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontFamilyFallback: ['sans-serif'],
              fontSize: 14,
              color: Color(0xFF6F6F7B),
            ),
          ),
          if (item.location != null || item.deadline != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (item.location != null)
                  _MetaChip(icon: Icons.location_on_outlined, label: item.location!),
                if (item.deadline != null)
                  _MetaChip(icon: Icons.event_outlined, label: item.deadline!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8B8B98)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontFamilyFallback: ['sans-serif'],
            fontSize: 13,
            color: Color(0xFF6F6F7B),
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
    required this.cardBorder,
  });

  final String title;
  final Widget child;
  final Color cardBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}