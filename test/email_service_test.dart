import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:careermate_ai/services/email_service.dart';

void main() {
  group('EmailService Tests', () {
    test('Returns EmailSendStatus.success when FormSubmit returns success: true', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'formsubmit.co') {
          final body = jsonDecode(request.body);
          expect(body['name'], 'John Doe');
          expect(body['email'], 'john@example.com');
          expect(body['_captcha'], 'false');
          expect(request.headers['Referer'], 'https://careermate-ai.com');

          return http.Response(
            jsonEncode({'success': 'true', 'message': 'Email sent successfully!'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await EmailService.sendFeedback(
        name: 'John Doe',
        userEmail: 'john@example.com',
        message: 'This is a test feedback message.',
        client: mockClient,
      );

      expect(result.status, EmailSendStatus.success);
      expect(result.isSuccess, isTrue);
    });

    test('Identifies activation pending status when FormSubmit requires activation', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'formsubmit.co') {
          return http.Response(
            jsonEncode({
              'success': 'false',
              'message': "This form needs Activation. We've sent you an email containing an 'Activate Form' link."
            }),
            200,
          );
        }
        if (request.url.host == 'api.web3forms.com') {
          return http.Response(
            jsonEncode({'success': false, 'message': 'Access key invalid'}),
            400,
          );
        }
        return http.Response('Error', 500);
      });

      final result = await EmailService.sendFeedback(
        name: 'Jane Doe',
        userEmail: 'jane@example.com',
        message: 'Testing activation handling in email service.',
        client: mockClient,
      );

      expect(
        result.status == EmailSendStatus.activationRequired ||
        result.status == EmailSendStatus.launchedMailto,
        isTrue,
      );
    });

    test('Falls back to Web3Forms if FormSubmit fails', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'formsubmit.co') {
          return http.Response('Server Error', 500);
        }
        if (request.url.host == 'api.web3forms.com') {
          return http.Response(
            jsonEncode({'success': true, 'message': 'Form submitted successfully'}),
            200,
          );
        }
        return http.Response('Error', 400);
      });

      final result = await EmailService.sendFeedback(
        name: 'Alex Smith',
        userEmail: 'alex@example.com',
        message: 'Testing fallback provider to Web3Forms.',
        client: mockClient,
      );

      expect(result.status, EmailSendStatus.success);
      expect(result.isSuccess, isTrue);
    });
  });
}
