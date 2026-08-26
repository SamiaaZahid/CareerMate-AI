import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/db_service.dart';
import '../services/email_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  static const Color primaryColor = AppColors.primaryPurple;
  static const Color backgroundColor = Color(0xFFF5F5F7);
  static const Color borderColor = Color(0xFFE8E1F5);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  TextStyle get _headlineStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Color(0xFF1F1F28),
      );

  TextStyle get _bodyStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 14,
        color: Color(0xFF6F6F7B),
      );

  TextStyle get _labelStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F1F28),
      );

  TextStyle get _fieldStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 15,
        color: Color(0xFF1F1F28),
      );

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _bodyStyle.copyWith(color: const Color(0xFF9A9AA6)),
      prefixIcon: Icon(icon, color: FeedbackScreen.primaryColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8D8E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: FeedbackScreen.primaryColor,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final message = _messageController.text.trim();

      await DbService.instance.saveFeedback(
        name: name,
        email: email,
        message: message,
      );

      final result = await EmailService.sendFeedback(
        name: name,
        userEmail: email,
        message: message,
      );

      if (!mounted) return;

      if (result.status == EmailSendStatus.success ||
          result.status == EmailSendStatus.activationRequired) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks! Your feedback has been sent to CareerMate AI.'),
            backgroundColor: FeedbackScreen.primaryColor,
          ),
        );
      } else if (result.status == EmailSendStatus.launchedMailto) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks! Your feedback has been sent to CareerMate AI.'),
            backgroundColor: AppColors.accentOrange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved feedback locally, but email delivery failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }

      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit feedback. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FeedbackScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: FeedbackScreen.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Send Feedback',
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontFamilyFallback: ['sans-serif'],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FeedbackScreen.borderColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'We value your feedback',
                        style: _headlineStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let us know how CareerMate AI can better support your career journey.',
                        style: _bodyStyle,
                      ),
                      const SizedBox(height: 24),
                      Text('Your Name', style: _labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: _fieldStyle,
                        decoration: _decoration(
                          hint: 'Enter your full name',
                          icon: Icons.person_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text('Email Address', style: _labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: _fieldStyle,
                        decoration: _decoration(
                          hint: 'Enter your email address',
                          icon: Icons.mail_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          final emailRegExp = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                          if (!emailRegExp.hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text('Message', style: _labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 5,
                        style: _fieldStyle,
                        decoration: _decoration(
                          hint: 'Write your feedback here (min 10 characters)...',
                          icon: Icons.chat_bubble_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your message';
                          }
                          if (value.trim().length < 10) {
                            return 'Message must be at least 10 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitFeedback,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Submit Feedback',
                                  style: TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontFamilyFallback: ['sans-serif'],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
