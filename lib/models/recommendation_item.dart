/// Type of recommendation being shown to the student.
enum RecommendationType { internship, scholarship }

/// Shared data model for an internship or scholarship recommendation.
///
/// Used by the Resume Analysis (listing) screen and the Program Details
/// screen, so both screens work off a single source of truth.
class RecommendationItemData {
  const RecommendationItemData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.requirements,
    this.location,
    this.deadline,
  });

  final RecommendationType type;
  final String title;
  final String subtitle;

  /// A short paragraph explaining what the program is about.
  final String description;

  /// Bullet points of eligibility / requirements.
  final List<String> requirements;

  final String? location;
  final String? deadline;
}