import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import 'gemini_service.dart';

/// Structured result of analyzing a resume against a target role.
///
/// This is what the UI renders instead of the old hardcoded 78/100
/// mock data — every field here comes from Gemini's actual read of
/// the user's resume text.
class ResumeAnalysisResult {
  const ResumeAnalysisResult({
    required this.score,
    required this.strengths,
    required this.improvements,
    required this.missingSkills,
  });

  final int score;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> missingSkills;
}

/// Calls Gemini with the user's extracted resume text and an
/// analysis-specific prompt, and parses the structured JSON reply.
///
/// This is deliberately a separate service from [GeminiService]'s chat
/// use (see `chat_service.dart`) — same account/API key, different job:
/// this one is single-turn, expects raw JSON back, and has nothing to
/// do with conversation history or function calling.
class ResumeAnalysisService {
  ResumeAnalysisService._();
  static final ResumeAnalysisService instance = ResumeAnalysisService._();

  /// Returns null if the resume text is empty, the API call fails, or
  /// the response can't be parsed as the expected JSON shape. Callers
  /// should treat null as "analysis unavailable" and show an error
  /// state rather than fake data.
  Future<ResumeAnalysisResult?> analyze({
    required String resumeText,
    String targetRole = 'Software Engineering',
  }) async {
    final trimmed = resumeText.trim();
    if (trimmed.isEmpty) {
      debugPrint('[ResumeAnalysisService] Empty resume text, skipping analysis.');
      return null;
    }

    final prompt = _buildPrompt(trimmed, targetRole);

    final result = await GeminiService.instance.send(
      contents: [GeminiChatTurn.user(prompt)],
    );

    if (result.text == null || result.text!.trim().isEmpty) {
      debugPrint('[ResumeAnalysisService] No usable text in Gemini response.');
      return null;
    }

    return _parseResponse(result.text!);
  }

  String _buildPrompt(String resumeText, String targetRole) {
    return '''
You are an expert technical recruiter reviewing a resume for a $targetRole internship or entry-level role.

Read the resume text below carefully, then respond with ONLY a raw JSON object — no markdown code fences, no backticks, no explanation before or after — matching exactly this shape:

{
  "score": <integer from 0 to 100 rating overall resume quality and fit for this role>,
  "strengths": [<3 to 4 short, specific strings describing what this exact resume does well>],
  "improvements": [<3 to 4 short, specific, actionable strings on what this exact resume should change or add>],
  "missingSkills": [<3 to 5 short strings naming specific skills or technologies commonly expected for this role that are absent from this resume>]
}

Base every field strictly on the resume text provided. Do not invent generic advice unrelated to what is actually in the resume.

Resume text:
"""
$resumeText
"""
''';
  }

  ResumeAnalysisResult? _parseResponse(String raw) {
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

      final rawScore = (decoded['score'] as num?)?.round() ?? 0;
      final score = rawScore < 0 ? 0 : (rawScore > 100 ? 100 : rawScore);

      final strengths = _stringList(decoded['strengths']);
      final improvements = _stringList(decoded['improvements']);
      final missingSkills = _stringList(decoded['missingSkills']);

      return ResumeAnalysisResult(
        score: score,
        strengths: strengths,
        improvements: improvements,
        missingSkills: missingSkills,
      );
    } catch (e, st) {
      debugPrint('[ResumeAnalysisService] Failed to parse Gemini response: $e\n$st\nRaw response: $raw');
      return null;
    }
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
  }
}