import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/skill_roadmap_model.dart';

/// Fetches skill roadmap templates from the Supabase `skill_roadmaps` table.
/// Mirrors the pattern used by ScholarshipService and InternshipService so
/// that roadmap content can be managed centrally instead of bundled as a
/// static asset. If the fetch fails, SkillRoadmapScreen falls back to its
/// built-in templates automatically.
class RoadmapService {
  Future<List<SkillRoadmapModel>> fetchRoadmaps() async {
    final data = await Supabase.instance.client
        .from('skill_roadmaps')
        .select()
        .order('created_at');

    final rows = List<Map<String, dynamic>>.from(data);

    return rows.map((row) {
      return SkillRoadmapModel.fromJson({
        'id': row['id'] ?? '',
        'role': row['role'] ?? '',
        'aliases': row['aliases'] ?? [],
        'description': row['description'] ?? '',
        'steps': row['steps'] ?? [],
      });
    }).toList();
  }
}