import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../config/api_keys.dart';

/// A single turn in a chat conversation. Holds raw Gemini "parts" so it
/// can represent plain text, a function call the model made, or the
/// result of running that function.
class GeminiChatTurn {
  const GeminiChatTurn._(this.role, this.parts);

  factory GeminiChatTurn.user(String text) => GeminiChatTurn._('user', [
        {'text': text}
      ]);

  factory GeminiChatTurn.model(String text) => GeminiChatTurn._('model', [
        {'text': text}
      ]);

  factory GeminiChatTurn.functionCall(String name, Map<String, dynamic> args, {String? thoughtSignature}) =>
      GeminiChatTurn._('model', [
        {
          'functionCall': {'name': name, 'args': args},
          'thoughtSignature': ?thoughtSignature,
        }
      ]);

  factory GeminiChatTurn.functionResponse(String name, Map<String, dynamic> response) =>
      GeminiChatTurn._('user', [
        {
          'functionResponse': {'name': name, 'response': response}
        }
      ]);

  final String role;
  final List<Map<String, dynamic>> parts;

  Map<String, dynamic> toJson() => {'role': role, 'parts': parts};
}

/// The result of a single call to Gemini: either a plain text reply, or
/// a request to run a specific action with some arguments.
class GeminiResult {
  const GeminiResult.text(this.text)
      : functionCallName = null,
        functionCallArgs = null,
        thoughtSignature = null;

  const GeminiResult.functionCall(this.functionCallName, this.functionCallArgs, {this.thoughtSignature}) : text = null;

  final String? text;
  final String? functionCallName;
  final Map<String, dynamic>? functionCallArgs;
  final String? thoughtSignature;

  bool get isFunctionCall => functionCallName != null;
}

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  static const String _model = 'gemini-3.6-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  Future<GeminiResult> send({
    required List<GeminiChatTurn> contents,
    String? systemInstruction,
    List<Map<String, dynamic>>? toolDeclarations,
  }) async {
    final uri = Uri.parse('$_baseUrl?key=$geminiApiKey');

    final body = <String, dynamic>{
      'contents': contents.map((turn) => turn.toJson()).toList(),
      if (systemInstruction != null && systemInstruction.trim().isNotEmpty)
        'systemInstruction': {
          'parts': [
            {'text': systemInstruction},
          ],
        },
      if (toolDeclarations != null && toolDeclarations.isNotEmpty)
        'tools': [
          {'functionDeclarations': toolDeclarations},
        ],
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        debugPrint('[GeminiService] API error ${response.statusCode}: ${response.body}');
        return const GeminiResult.text(
          'Sorry, I ran into a problem reaching the AI service. Please try again in a moment.',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;

      if (candidates == null || candidates.isEmpty) {
        debugPrint('[GeminiService] No candidates in response: ${response.body}');
        return const GeminiResult.text("Sorry, I couldn't come up with a response for that. Could you rephrase?");
      }

      final parts = (candidates.first as Map<String, dynamic>)['content']['parts'] as List<dynamic>;

      for (final part in parts) {
        final map = part as Map<String, dynamic>;
        if (map.containsKey('functionCall')) {
          final call = map['functionCall'] as Map<String, dynamic>;
          return GeminiResult.functionCall(
            call['name'] as String,
            (call['args'] as Map<String, dynamic>?) ?? {},
            thoughtSignature: map['thoughtSignature'] as String?,
          );
        }
      }

      final text = parts.map((part) => (part as Map<String, dynamic>)['text'] ?? '').join().trim();

      return GeminiResult.text(
        text.isEmpty ? "Sorry, I couldn't come up with a response for that. Could you rephrase?" : text,
      );
    } catch (e) {
      debugPrint('[GeminiService] Exception during API call: $e');
      return const GeminiResult.text('Sorry, something went wrong while contacting the AI service.');
    }
  }
}