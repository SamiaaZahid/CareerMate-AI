import 'package:flutter_test/flutter_test.dart';

import 'package:careermate_ai/main.dart';

void main() {
  testWidgets('App loads LoginScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen title and login button are displayed.
    expect(find.text('CareerMate AI'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
  });
}
