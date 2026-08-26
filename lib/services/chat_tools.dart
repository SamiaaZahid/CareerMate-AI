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
      'description': 'Turns dark mode on or off in the app.',
      'parameters': {
        'type': 'OBJECT',
        'properties': {
          'enabled': {
            'type': 'BOOLEAN',
            'description': 'true to turn dark mode on, false to turn it off.',
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

  static Future<String> _setDarkMode(Map<String, dynamic> args) async {
    final enabled = args['enabled'] == true;
    await ThemeService.instance.setDarkMode(enabled);
    return enabled ? 'Dark mode has been turned on.' : 'Dark mode has been turned off.';
  }
}