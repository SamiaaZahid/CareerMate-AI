import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const Color primaryColor = AppColors.primaryPurple;
  static const Color accentColor = AppColors.accentOrange;
  static const Color backgroundColor = Color(0xFFF5F5F7);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  TextStyle get _headlineStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontWeight: FontWeight.bold,
        fontSize: 28,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginScreen.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8E1F5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE8E1F5),
                            width: 6,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F3FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.image_outlined,
                              color: LoginScreen.accentColor,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'CareerMate AI',
                      textAlign: TextAlign.center,
                      style: _headlineStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your personal AI career mentor.',
                      textAlign: TextAlign.center,
                      style: _bodyStyle,
                    ),
                    const SizedBox(height: 28),
                    Text('Email Address', style: _labelStyle),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: _fieldStyle,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: _bodyStyle.copyWith(
                          color: const Color(0xFF9A9AA6),
                        ),
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: LoginScreen.primaryColor,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD8D8E3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: LoginScreen.primaryColor,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Password', style: _labelStyle),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: LoginScreen.accentColor,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot?',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontFamilyFallback: ['sans-serif'],
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: _fieldStyle,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: _bodyStyle.copyWith(
                          color: const Color(0xFF9A9AA6),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: LoginScreen.primaryColor,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF7D7D8A),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD8D8E3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: LoginScreen.primaryColor,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (!mounted) return;
                                setState(() => _isLoading = true);
                                try {
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text;
                                  final messenger = ScaffoldMessenger.of(context);
                                  if (email.isEmpty || password.isEmpty) {
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text('Please provide email and password')),
                                    );
                                    return;
                                  }
                                  final err = await AuthService.instance.login(email: email, password: password);
                                  if (err != null) {
                                    messenger.showSnackBar(SnackBar(content: Text(err)));
                                    return;
                                  }
                                  if (!context.mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                  );
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Unable to sign in. Please try again.')),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontFamilyFallback: ['sans-serif'],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: _bodyStyle.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF5F5F6B),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: LoginScreen.accentColor,
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: 'Be Vietnam Pro',
                                fontFamilyFallback: ['sans-serif'],
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
