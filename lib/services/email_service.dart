import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'web_helpers_stub.dart' if (dart.library.js_interop) 'web_helpers.dart';

class EmailService {
  static const String adminEmail = 'rautvedant14@gmail.com';

  static Future<bool> sendFeedbackEmail({
    required String name,
    required String userEmail,
    required String message,
  }) async {
    final timestamp = DateTime.now().toIso8601String();

    // 1. Direct HTTP Email Dispatch via FormSubmit AJAX endpoint (zero-config, free delivery to adminEmail)
    try {
      final response = await http.post(
        Uri.parse('https://formsubmit.co/ajax/$adminEmail'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': userEmail,
          '_subject': 'CareerMate AI Feedback from $name',
          'message': message,
          'timestamp': timestamp,
          '_template': 'table',
        }),
      );

      debugPrint('[EmailService] FormSubmit HTTP status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[EmailService] Feedback email successfully sent to $adminEmail!');
        return true;
      }
    } catch (e) {
      debugPrint('[EmailService] FormSubmit HTTP exception: $e');
    }

    // 2. Safe Mailto Fallback
    try {
      final subject = Uri.encodeComponent('CareerMate AI Feedback from $name');
      final body = Uri.encodeComponent(
        'Feedback Submission:\n\n'
        'Name: $name\n'
        'Email: $userEmail\n'
        'Timestamp: $timestamp\n\n'
        'Message:\n$message',
      );
      final mailtoUrl = 'mailto:$adminEmail?subject=$subject&body=$body';

      if (kIsWeb) {
        openWebUrl(mailtoUrl);
      } else {
        final mailtoUri = Uri.parse(mailtoUrl);
        if (await canLaunchUrl(mailtoUri)) {
          await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('[EmailService] Mailto launcher exception: $e');
    }

    return true;
  }
}
