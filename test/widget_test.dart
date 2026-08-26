import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careermate_ai/main.dart';
import 'package:careermate_ai/screens/login_screen.dart';

void main() {
  testWidgets('MyApp renders correctly with LoginScreen as initial route',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
