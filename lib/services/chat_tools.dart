import 'theme_service.dart';

typedef ToolExecutor = Future<String> Function(Map<String, dynamic> args);

/// Actions the AI chat is allowed to actually perform in the app, not
/// just describe. Each action needs two things: a declaration (so
/// Gemini knows the action exists and what arguments it takes) and an
/// executor (the real Dart code that performs it).
///
/// To add a new action later: add one entry to [declarations] and one
/// entry to [_executors]. That's the one manual step this can't remove
/// — a brand new action is, by definition, something nothing has been
/// told how to do yet.
class ChatTools {
  ChatTools._();

  static const List<Map<String, dynamic>> declarations = [
    {
      'name': 'set_dark_mode',
      'description':
          'Turns dark mode on or off in the app (this also controls light mode: '
          'turning dark mode off is the same as turning light mode on, and vice versa). '
          'Use this whenever the user asks to switch to dark mode, light mode, '
          'or otherwise change the app\'s color theme.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'enabled': {
            'type': 'BOOLEAN',
            'description':
                'true to turn dark mode on (light mode off), false to turn '
                'dark mode off (light mode on).',
          },
        },
        'required': ['enabled'],
      },
    },
  ];

  static final Map<String, ToolExecutor> _executors = {
    'set_dark_mode': _setDarkMode,
  };

  static Future<String> execute(String name, Map<String, dynamic> args) async {
    final executor = _executors[name];
    if (executor == null) {
      return 'That action is not available yet.';
    }
    return executor(args);
  }

  /// Reads a bool out of [args] defensively. Gemini's function-call
  /// arguments are expected to come back as a real bool, but if a string
  /// like "true"/"false" (or a stray num like 1/0) ever slips through
  /// instead, this still resolves it correctly instead of silently
  /// defaulting to false.
  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.trim().toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  static Future<String> _setDarkMode(Map<String, dynamic> args) async {
    final enabled = _readBool(args['enabled']);
    await ThemeService.instance.setDarkMode(enabled);
    return enabled ? 'Dark mode has been turned on.' : 'Dark mode has been turned off.';
  }
}