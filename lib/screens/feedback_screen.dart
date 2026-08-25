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

  TextStyle get _headlineStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Theme.of(context).colorScheme.onSurface,
      );

  TextStyle get _bodyStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 14,
        color: Color(0xFF6F6F7B),
      );

  TextStyle get _labelStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      );

  TextStyle get _fieldStyle => TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: const ['sans-serif'],
        fontSize: 15,
        color: Theme.of(context).colorScheme.onSurface,
      );

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    required Color primaryColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: _bodyStyle.copyWith(color: const Color(0xFF9A9AA6)),
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF2C2C35) : const Color(0xFFD8D8E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: primaryColor,
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

      await EmailService.sendFeedbackEmail(
        name: name,
        userEmail: email,
        message: message,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank! your feedback has been sent to career mate Ai'),
          backgroundColor: FeedbackScreen.primaryColor,
        ),
      );

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF9D7BEE) : FeedbackScreen.primaryColor;
    final cardBorder = isDark ? const Color(0xFF2C2C35) : FeedbackScreen.borderColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : FeedbackScreen.primaryColor,
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
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
                          primaryColor: primaryColor,
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
                          primaryColor: primaryColor,
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
                          primaryColor: primaryColor,
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
