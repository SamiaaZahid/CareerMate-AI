import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scholarship_model.dart';

class ScholarshipService {
  Future<List<Scholarship>> fetchScholarships() async {
    final data = await Supabase.instance.client
        .from('scholarships')
        .select()
        .order('created_at');

    final rows = List<Map<String, dynamic>>.from(data);

    return rows.map((row) {
      return Scholarship.fromJson({
        'id': row['id'],
        'title': row['title'] ?? '',
        'provider': row['provider'] ?? '',
        'amount': row['amount'] ?? '',
        'deadline': row['deadline'] ?? '',
        'shortDescription': row['short_description'] ?? '',
        'fullDescription': row['full_description'] ?? '',
        'eligibility': row['eligibility'] ?? '',
        'icon': row['icon'] ?? 'school',
      });
    }).toList();
  }
}