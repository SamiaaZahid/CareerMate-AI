import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/scholarship_model.dart';

class ScholarshipService {
  Future<List<Scholarship>> fetchScholarships() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final String jsonString = await rootBundle.loadString('assets/data/scholarships.json');
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

    return jsonList
        .map((json) => Scholarship.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
