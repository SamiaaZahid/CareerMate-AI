import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle, AssetManifest;

import 'auth_service.dart';

/// Assembles the context the AI chat needs to answer questions, pulled
/// fresh from live app data every time it's called.
///
/// This is written to be generic on purpose:
/// - Any JSON file dropped into lib/data/ is picked up automatically,
///   whatever it's named and whatever fields it contains.
/// - Any field on the logged-in user's profile row is included
///   automatically, whatever it's called — so a new column added to the
///   users table (e.g. a future skill roadmap summary, resume score,
///   etc.) shows up here with no code change.
///
/// It does NOT know about brand-new features that store data somewhere
/// this builder never looks (e.g. a new database table). If a teammate
/// adds one of those, add one short block here pointing at it — that's
/// the one manual step this design can't remove.
class ChatContextBuilder {
  ChatContextBuilder._();

  static const String _appKnowledge = '''
CareerMate AI is a mobile app that helps students find internships and
scholarships and plan their career skills. It has these main screens:

- Home: entry point, shortcuts to programs, resume analysis, and profile.
- Program Listing: browse internships and scholarships.
- Resume Analysis: suggested internships/scholarships and skill gaps.
- Profile: the student's personal info and uploaded resume.
- Settings: account details and app preferences.

Some features may still be under construction ("coming soon") — if the
user asks about one that isn't described with real data below, say it's
not available yet rather than guessing.
''';

  /// Fields on the user row that should never be shown to the AI or user.
  static const Set<String> _hiddenUserFields = {'id', 'password'};

  static Future<String> build() async {
    final buffer = StringBuffer();

    buffer.writeln(
      'You are the AI assistant inside CareerMate AI, a student-facing '
      'internship and scholarship app. Answer questions using only the '
      'information given below. If something is not covered, say you are '
      'not sure rather than guessing. Keep replies short and friendly.',
    );
    buffer.writeln();
    buffer.writeln('--- ABOUT THE APP ---');
    buffer.writeln(_appKnowledge);

    buffer.writeln('--- CURRENT USER ---');
    buffer.writeln(await _buildUserContext());

    buffer.writeln('--- APP DATA ---');
    buffer.writeln(await _buildDataFilesContext());

    return buffer.toString();
  }

  /// Includes every field present on the user's row, whatever it's
  /// called. New columns show up automatically, nothing to update here.
  static Future<String> _buildUserContext() async {
    final user = await AuthService.instance.getCurrentUser();

    if (user == null) {
      return 'No user is currently logged in.';
    }

    final buffer = StringBuffer();
    for (final entry in user.entries) {
      if (_hiddenUserFields.contains(entry.key)) continue;
      final value = entry.value;
      if (value == null || value.toString().trim().isEmpty) continue;

      final label = _humanizeFieldName(entry.key);
      buffer.writeln('$label: $value');
    }

    final result = buffer.toString();
    return result.isEmpty ? 'This user has not filled in a profile yet.' : result;
  }

  /// Discovers every JSON file under lib/data/ via the asset manifest,
  /// loads each one, and describes its contents generically. A teammate
  /// adding a new data file (e.g. scholarships.json, skill_roadmap.json)
  /// needs no code change here — it's picked up on the next app run.
  static Future<String> _buildDataFilesContext() async {
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);

      final dataFiles = assetManifest
          .listAssets()
          .where((path) => path.startsWith('lib/data/') && path.endsWith('.json'))
          .toList()
        ..sort();

      if (dataFiles.isEmpty) {
        return 'No app data files were found.';
      }

      final buffer = StringBuffer();
      for (final path in dataFiles) {
        buffer.writeln('# Data from $path:');
        buffer.writeln(await _describeJsonFile(path));
        buffer.writeln();
      }
      return buffer.toString();
    } catch (e) {
      return 'App data could not be loaded right now.';
    }
  }

  static Future<String> _describeJsonFile(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);

      if (decoded is List) {
        if (decoded.isEmpty) return '(empty list)';
        final buffer = StringBuffer();
        for (final item in decoded) {
          buffer.writeln('- ${_describeValue(item)}');
        }
        return buffer.toString();
      }

      if (decoded is Map) {
        return _describeValue(decoded);
      }

      return decoded.toString();
    } catch (e) {
      return '(could not read this file)';
    }
  }

  /// Turns any JSON value (map, list, or scalar) into readable text
  /// without assuming specific field names.
  static String _describeValue(dynamic value) {
    if (value is Map) {
      return value.entries
          .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
          .map((e) => '${_humanizeFieldName(e.key.toString())}: ${_describeValue(e.value)}')
          .join(', ');
    }
    if (value is List) {
      return value.map(_describeValue).join('; ');
    }
    return value.toString();
  }

  static String _humanizeFieldName(String field) {
    final withSpaces = field.replaceAll('_', ' ');
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }
}