import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'web_helpers_stub.dart' if (dart.library.js_interop) 'web_helpers.dart';

enum EmailSendStatus {
  success,
  activationRequired,
  launchedMailto,
  failed,
}

class EmailSendResult {
  final EmailSendStatus status;
  final String message;

  const EmailSendResult({
    required this.status,
    required this.message,
  });

  bool get isSuccess =>
      status == EmailSendStatus.success ||
      status == EmailSendStatus.launchedMailto;
}

class EmailService {
  static const String adminEmail = 'rautvedant14@gmail.com';

  /// Sends feedback email and returns detailed [EmailSendResult].
  static Future<EmailSendResult> sendFeedback({
    required String name,
    required String userEmail,
    required String message,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final timestamp = DateTime.now().toIso8601String();

    // 1. Direct HTTP Email Dispatch via FormSubmit AJAX endpoint
    try {
      final response = await httpClient.post(
        Uri.parse('https://formsubmit.co/ajax/$adminEmail'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Referer': 'https://careermate-ai.com',
          'Origin': 'https://careermate-ai.com',
          'User-Agent': 'CareerMateAI/1.0',
        },
        body: jsonEncode({
          'name': name,
          'email': userEmail,
          '_replyto': userEmail,
          '_subject': 'CareerMate AI Feedback from $name',
          'message': message,
          'timestamp': timestamp,
          '_template': 'table',
          '_captcha': 'false',
        }),
      );

      debugPrint('[EmailService] FormSubmit status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> jsonBody = jsonDecode(response.body);
          final String isSuccessStr = jsonBody['success']?.toString().toLowerCase() ?? '';
          final String responseMessage = jsonBody['message']?.toString() ?? '';

          if (isSuccessStr == 'true') {
            debugPrint('[EmailService] Feedback email successfully sent to $adminEmail via FormSubmit!');
            return const EmailSendResult(
              status: EmailSendStatus.success,
              message: 'Feedback submitted successfully!',
            );
          } else if (responseMessage.toLowerCase().contains('activation') ||
              responseMessage.toLowerCase().contains('activate')) {
            debugPrint('[EmailService] FormSubmit activation pending for $adminEmail');
            // Try mailto fallback so feedback is not lost while activation is pending
            final mailtoSuccess = await _launchMailtoFallback(name: name, userEmail: userEmail, message: message, timestamp: timestamp);
            return EmailSendResult(
              status: mailtoSuccess ? EmailSendStatus.launchedMailto : EmailSendStatus.activationRequired,
              message: 'FormSubmit requires activation link confirmation sent to $adminEmail.',
            );
          }
        } catch (e) {
          debugPrint('[EmailService] Error parsing FormSubmit JSON response: $e');
        }
      }
    } catch (e) {
      debugPrint('[EmailService] FormSubmit HTTP exception: $e');
    }

    // 2. Web3Forms API Backup Endpoint
    try {
      final web3Response = await httpClient.post(
        Uri.parse('https://api.web3forms.com/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'access_key': '43673f15-8947-4952-b883-8a3fb70c9df7',
          'subject': 'CareerMate AI Feedback from $name',
          'from_name': name,
          'email': userEmail,
          'message': message,
        }),
      );

      debugPrint('[EmailService] Web3Forms status: ${web3Response.statusCode}, body: ${web3Response.body}');
      if (web3Response.statusCode == 200 || web3Response.statusCode == 201) {
        final Map<String, dynamic> jsonBody = jsonDecode(web3Response.body);
        if (jsonBody['success'] == true || jsonBody['success']?.toString().toLowerCase() == 'true') {
          debugPrint('[EmailService] Feedback email successfully sent via Web3Forms!');
          return const EmailSendResult(
            status: EmailSendStatus.success,
            message: 'Feedback submitted successfully!',
          );
        }
      }
    } catch (e) {
      debugPrint('[EmailService] Web3Forms HTTP exception: $e');
    }

    // 3. Safe Mailto Fallback
    final mailtoLaunched = await _launchMailtoFallback(
      name: name,
      userEmail: userEmail,
      message: message,
      timestamp: timestamp,
    );

    if (mailtoLaunched) {
      return const EmailSendResult(
        status: EmailSendStatus.launchedMailto,
        message: 'Opened email app to send feedback.',
      );
    }

    return const EmailSendResult(
      status: EmailSendStatus.failed,
      message: 'Failed to send feedback email. Please try again.',
    );
  }

  /// Backwards-compatible helper method
  static Future<bool> sendFeedbackEmail({
    required String name,
    required String userEmail,
    required String message,
  }) async {
    final result = await sendFeedback(
      name: name,
      userEmail: userEmail,
      message: message,
    );
    return result.isSuccess;
  }

  static Future<bool> _launchMailtoFallback({
    required String name,
    required String userEmail,
    required String message,
    required String timestamp,
  }) async {
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
        return true;
      } else {
        final mailtoUri = Uri.parse(mailtoUrl);
        if (await canLaunchUrl(mailtoUri)) {
          return await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('[EmailService] Mailto launcher exception: $e');
    }
    return false;
  }
}

