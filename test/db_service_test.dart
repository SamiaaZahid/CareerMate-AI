import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:careermate_ai/services/db_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DbService Feedback Tests', () {
    test('saveFeedback persists feedback record', () async {
      SharedPreferences.setMockInitialValues({});

      final id = await DbService.instance.saveFeedback(
        name: 'Test User',
        email: 'test@example.com',
        message: 'Great app for career development!',
      );

      expect(id, greaterThan(0));
    });
  });
}
