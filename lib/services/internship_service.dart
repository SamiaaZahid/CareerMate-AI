import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recommendation_item.dart';

/// Fetches internships from the Supabase `internships` table.
/// Replaces the old approach of reading assets/data/programs.json directly,
/// so edits made in Manage Data show up here immediately for every user.
class InternshipService {
  Future<List<RecommendationItemData>> fetchInternships() async {
    final data = await Supabase.instance.client
        .from('internships')
        .select()
        .order('created_at');

    final rows = List<Map<String, dynamic>>.from(data);

    return rows.map((row) {
      return RecommendationItemData.fromJson({
        'type': row['type'] ?? 'internship',
        'title': row['title'] ?? '',
        'subtitle': row['subtitle'] ?? '',
        'description': row['description'] ?? '',
        'requirements': row['requirements'] ?? [],
        'location': row['location'],
        'deadline': row['deadline'],
        'skills': row['skills'] ?? [],
      });
    }).toList();
  }
}