import 'package:flutter/material.dart';
import '../services/internship_service.dart';

import '../constants/app_colors.dart';
import '../models/recommendation_item.dart';
import '../services/scholarship_service.dart';
import '../services/theme_service.dart';
import 'program_details_screen.dart';

class ProgramListingScreen extends StatefulWidget {
  const ProgramListingScreen({super.key, this.initialFilter = 'all'});

  final String initialFilter;

  static const Color primaryColor = AppColors.primaryPurple;
  static const Color backgroundColor = Color(0xFFF5F5F7);
  static const Color borderColor = Color(0xFFE8E1F5);

  @override
  State<ProgramListingScreen> createState() => _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  late String _selectedFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<RecommendationItemData> _allPrograms = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _loadPrograms();
  }

  /// Loads internships from programs.json and scholarships from
  /// scholarships.json (the same dataset behind the dedicated Scholarships
  /// tab), then merges them. Two separate files because they're two
  /// separate features with different detail screens — but both are now
  /// real, and a scholarship shown here is always identical to the one
  /// shown in the Scholarships tab, never a second drifting copy.
  Future<void> _loadPrograms() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final internships = await InternshipService().fetchInternships();

      final scholarships = await ScholarshipService().fetchScholarships();
      final scholarshipItems =
          scholarships.map((s) => RecommendationItemData.fromScholarship(s)).toList();

      if (!mounted) return;
      setState(() {
        _allPrograms = [...internships, ...scholarshipItems];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[ProgramListingScreen] Failed to load programs: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecommendationItemData> get _filteredPrograms {
    return _allPrograms.where((item) {
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'internships' && item.type == RecommendationType.internship) ||
          (_selectedFilter == 'scholarships' && item.type == RecommendationType.scholarship);

      final query = _searchQuery.toLowerCase();
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          (item.location ?? '').toLowerCase().contains(query);

      return matchesFilter && matchesQuery;
    }).toList();
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
              'Internships & Programs',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontFamilyFallback: ['sans-serif'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: colors.surfaceCard,
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 14,
                          color: colors.primaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search internships, skills, companies...',
                          hintStyle: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 14,
                            color: colors.subtitleText,
                          ),
                          prefixIcon: const Icon(Icons.search, color: AppColors.accentOrange),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: colors.subtitleText),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: colors.inputFillColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colors.primaryPurple,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: _selectedFilter == 'all',
                            colors: colors,
                            onTap: () => setState(() => _selectedFilter = 'all'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Internships',
                            isSelected: _selectedFilter == 'internships',
                            colors: colors,
                            onTap: () => setState(() => _selectedFilter = 'internships'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Scholarships',
                            isSelected: _selectedFilter == 'scholarships',
                            colors: colors,
                            onTap: () => setState(() => _selectedFilter = 'scholarships'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: colors.primaryPurple),
                        )
                      : _hasError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline_rounded, size: 48, color: colors.subtitleText),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Couldn\'t load opportunities',
                                    style: TextStyle(
                                      fontFamily: 'Be Vietnam Pro',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: _loadPrograms,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _filteredPrograms.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: colors.subtitleText),
                              const SizedBox(height: 12),
                              Text(
                                'No opportunities found',
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try adjusting your search query or filters',
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontSize: 14,
                                  color: colors.subtitleText,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPrograms.length,
                          itemBuilder: (context, index) {
                            final item = _filteredPrograms[index];
                            return _ProgramCard(item: item, colors: colors);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final AppThemeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryPurple : colors.chipBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? colors.primaryPurple : colors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : colors.primaryPurple,
          ),
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.item,
    required this.colors,
  });

  final RecommendationItemData item;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final bool isInternship = item.type == RecommendationType.internship;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isInternship ? Icons.work_outline : Icons.school_outlined,
                      size: 14,
                      color: colors.primaryPurple,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isInternship ? 'Internship' : 'Scholarship',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (item.deadline != null)
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 14, color: colors.subtitleText),
                    const SizedBox(width: 4),
                    Text(
                      item.deadline!,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 12,
                        color: colors.subtitleText,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.subtitleText,
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 16),
          Row(
            children: [
              if (item.location != null)
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: colors.subtitleText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 12,
                            color: colors.subtitleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: 38,
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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