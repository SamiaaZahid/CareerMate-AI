import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../config/api_keys.dart';

/// A single turn in a chat conversation, used to build up history
/// that gets sent to Gemini alongside each new message.
class GeminiChatTurn {
  const GeminiChatTurn({required this.role, required this.text});

  /// Either 'user' or 'model'.
  final String role;
  final String text;
}

/// Thin wrapper around the Gemini generateContent REST API.
///
/// This service only knows how to talk to Gemini. It has no idea about
/// CareerMate AI's users, programs, or screens — that context is built
/// separately and passed in as [systemInstruction].
class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  static const String _model = 'gemini-3.6-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  Future<String> sendMessage({
    required String userMessage,
    String? systemInstruction,
    List<GeminiChatTurn> history = const [],
  }) async {
    final uri = Uri.parse('$_baseUrl?key=$geminiApiKey');

    final contents = [
      ...history.map(
        (turn) => {
          'role': turn.role,
          'parts': [
            {'text': turn.text},
          ],
        },
      ),
      {
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      },
    ];

    final body = <String, dynamic>{
      'contents': contents,
      if (systemInstruction != null && systemInstruction.trim().isNotEmpty)
        'systemInstruction': {
          'parts': [
            {'text': systemInstruction},
          ],
        },
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        debugPrint('[GeminiService] API error ${response.statusCode}: ${response.body}');
        return 'Sorry, I ran into a problem reaching the AI service. Please try again in a moment.';
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;

      if (candidates == null || candidates.isEmpty) {
        debugPrint('[GeminiService] No candidates in response: ${response.body}');
        return "Sorry, I couldn't come up with a response for that. Could you rephrase?";
      }

      final parts = (candidates.first as Map<String, dynamic>)['content']['parts'] as List<dynamic>;
      final text = parts.map((part) => (part as Map<String, dynamic>)['text'] ?? '').join();

      return text.toString().trim().isEmpty
          ? "Sorry, I couldn't come up with a response for that. Could you rephrase?"
          : text.toString().trim();
    } catch (e) {
      debugPrint('[GeminiService] Exception during API call: $e');
      return 'Sorry, something went wrong while contacting the AI service.';
    }
  }
}