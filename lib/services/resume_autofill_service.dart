import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import 'gemini_service.dart';

/// Suggested profile-field values extracted from a resume by Gemini.
///
/// This is only ever a *suggestion* — [ProfileAutofillService] never writes
/// to the database or to any controller itself. The caller (the profile
/// screen) is responsible for showing these to the user for review and
/// only applying whichever fields the user explicitly confirms.
class ProfileAutofillSuggestion {
  const ProfileAutofillSuggestion({
    required this.yearOfStudy,
    required this.skills,
    required this.careerGoals,
  });

  /// One of the caller-supplied valid year options, or null if the resume
  /// gave no clear signal (e.g. no dates/education section).
  final String? yearOfStudy;

  /// Skills Gemini found evidence of in the resume text. May overlap with
  /// skills the user already has saved — the caller should filter those
  /// out before showing them as "new" suggestions.
  final List<String> skills;

  /// A short, resume-grounded career goals statement, or null if the
  /// resume doesn't give enough to infer one (e.g. no objective/summary
  /// and no clear career trajectory).
  final String? careerGoals;

  bool get isEmpty =>
      (yearOfStudy == null) && skills.isEmpty && (careerGoals == null || careerGoals!.trim().isEmpty);
}

/// Calls Gemini with the user's extracted resume text and asks it to
/// suggest values for a few profile fields (year of study, key skills,
/// career goals), so the user doesn't have to retype what's already in
/// their resume.
///
/// This is deliberately read-only / suggestion-only: it never touches the
/// database. See [ProfileAutofillSuggestion] for the contract.
class ProfileAutofillService {
  ProfileAutofillService._();
  static final ProfileAutofillService instance = ProfileAutofillService._();

  /// Returns null if the resume text is empty, the API call fails, or the
  /// response can't be parsed as the expected JSON shape. Callers should
  /// treat null as "couldn't generate suggestions" and fail quietly rather
  /// than block the profile screen.
  Future<ProfileAutofillSuggestion?> suggestProfileFields({
    required String resumeText,
    required List<String> validYearOptions,
    required List<String> existingSkills,
  }) async {
    final trimmed = resumeText.trim();
    if (trimmed.isEmpty) {
      debugPrint('[ProfileAutofillService] Empty resume text, skipping autofill.');
      return null;
    }

    final prompt = _buildPrompt(
      resumeText: trimmed,
      validYearOptions: validYearOptions,
      existingSkills: existingSkills,
    );

    final result = await GeminiService.instance.send(
      contents: [GeminiChatTurn.user(prompt)],
    );

    if (result.text == null || result.text!.trim().isEmpty) {
      debugPrint('[ProfileAutofillService] No usable text in Gemini response.');
      return null;
    }

    return _parseResponse(result.text!, validYearOptions);
  }

  String _buildPrompt({
    required String resumeText,
    required List<String> validYearOptions,
    required List<String> existingSkills,
  }) {
    final yearOptionsJson = jsonEncode(validYearOptions);
    final existingSkillsJson = jsonEncode(existingSkills);

    return '''
You are helping a student fill in their internship-matching profile from their resume.

Read the resume text below, then respond with ONLY a raw JSON object — no markdown code fences, no backticks, no explanation before or after — matching exactly this shape:

{
  "yearOfStudy": <one of the strings in $yearOptionsJson that best matches the resume's education section, or null if it genuinely cannot be determined>,
  "skills": [<every specific skill, tool, language, or technology the resume provides real evidence for — projects, coursework, work experience, or a skills section. Do not include anything from this list already known: $existingSkillsJson>],
  "careerGoals": <a short 1-2 sentence career goals statement written in first person ("I want to..."), grounded in the resume's actual experience/trajectory, or null if there's not enough signal to infer one honestly>
}

Rules:
- Only use "yearOfStudy" values from the exact list provided. Never invent a new one.
- Do not fabricate skills that aren't actually evidenced in the text.
- Do not fabricate a career goals statement that isn't reasonably supported by the resume's content — return null instead of generic filler.

Resume text:
"""
$resumeText
"""
''';
  }

  ProfileAutofillSuggestion? _parseResponse(String raw, List<String> validYearOptions) {
    try {
      var cleaned = raw.trim();

      // Gemini sometimes wraps JSON in ```json ... ``` despite instructions.
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```[a-zA-Z]*\s*'), '');
        if (cleaned.endsWith('```')) {
          cleaned = cleaned.substring(0, cleaned.length - 3);
        }
        cleaned = cleaned.trim();
      }

      final decoded = jsonDecode(cleaned) as Map<String, dynamic>;

      final rawYear = (decoded['yearOfStudy'] as String?)?.trim();
      // Defensive: only accept a year value that's actually one of the
      // options we offered. If Gemini returns something off-list, treat it
      // as "couldn't determine" rather than injecting a bad dropdown value.
      final year = (rawYear != null && validYearOptions.contains(rawYear)) ? rawYear : null;

      final skills = _stringList(decoded['skills']);

      final rawGoals = (decoded['careerGoals'] as String?)?.trim();
      final goals = (rawGoals == null || rawGoals.isEmpty || rawGoals.toLowerCase() == 'null') ? null : rawGoals;

      return ProfileAutofillSuggestion(
        yearOfStudy: year,
        skills: skills,
        careerGoals: goals,
      );
    } catch (e, st) {
      debugPrint('[ProfileAutofillService] Failed to parse Gemini response: $e\n$st\nRaw response: $raw');
      return null;
    }
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
  }
}