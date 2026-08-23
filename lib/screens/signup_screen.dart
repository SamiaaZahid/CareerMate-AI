import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const Color primaryColor = AppColors.primaryPurple;
  static const Color accentColor = AppColors.accentOrange;
  static const Color backgroundColor = Color(0xFFF5F5F7);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController =TextEditingController();
  final TextEditingController _emailController =TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =TextEditingController();

  TextStyle get _headlineStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontWeight: FontWeight.bold,
        fontSize: 26,
        color: Color.fromARGB(255, 20, 17, 20),
      );

  TextStyle get _bodyStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 14,
        color: Color.fromARGB(255, 121, 111, 123),
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
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _bodyStyle.copyWith(
        color: const Color(0xFF9A9AA6),
      ),
      prefixIcon: Icon(
        icon,
        color: SignUpScreen.primaryColor,
      ),
      suffixIcon: suffixIcon,
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
          color: SignUpScreen.primaryColor, width: 1.4, ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent,),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4,),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final messenger = ScaffoldMessenger.of(context);

      final err = await AuthService.instance.signUp(
        name: name,
        email: email,
        password: password,
      );

      if (err != null) {
        messenger.showSnackBar( SnackBar( content: Text(err),), );
        return;
      }

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar( content: Text(  'Account created successfully!',),
          backgroundColor: AppColors.primaryPurple,
        ),
      );

      Navigator.pushReplacement( context,MaterialPageRoute( builder: (context) => const LoginScreen(),),);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text( 'Failed to create account. Please try again.', ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState( () => _isLoading = false,); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SignUpScreen.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SignupBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),

                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 350,
                  ),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 20,
                    ),

                    decoration: BoxDecoration(
                      color: const Color.fromARGB(183, 255, 255, 255),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all( color: const Color(0xFFE8E1F5),),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center( child: Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                 color: const Color(0xFFE8E1F5), width: 6,
                                ),
                              ),

                              child: ClipOval(
                                child: Image.asset( 'assets/images/excelerate_logo.png',
                                  width: 96, height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person_add_outlined,
                                      color:  SignUpScreen.primaryColor,
                                      size: 34 );
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),
                          Text( 'Create Your Account', textAlign: TextAlign.center, style: _headlineStyle,),
                          const SizedBox(height: 7),
                          Text('Start your journey with CareerMate AI.', textAlign: TextAlign.center, style: _bodyStyle,),

                          const SizedBox(height: 24),
                          Text('Full Name', style: _labelStyle,),

                          const SizedBox(height: 7),
                          TextFormField(
                            controller: _nameController,
                            style: _fieldStyle,
                            decoration: _decoration(
                              hint: 'Enter your full name',
                              icon: Icons.person_outline,
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),
                          Text('Email Address',style: _labelStyle,),

                          const SizedBox(height: 7),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: _fieldStyle,
                            decoration: _decoration(
                              hint: 'Enter your email',
                              icon: Icons.mail_outline,
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your email';
                              }

                              final emailRegExp = RegExp(  r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$", );

                              if (!emailRegExp.hasMatch(
                                value.trim(),
                              )) { return 'Please enter a valid email address'; }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),
                          Text('Password',  style: _labelStyle,),

                          const SizedBox(height: 7),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: _fieldStyle,
                            decoration: _decoration(
                              hint: 'Create a password',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },

                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF7D7D8A),
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please create a password';
                              }

                              if (value.length < 6) { return 'Password must be at least 6 characters'; }

                              return null;
                            },
                          ),

                          const SizedBox(height: 14),
                          Text( 'Confirm Password', style: _labelStyle, ),

                          const SizedBox(height: 7),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: _fieldStyle,
                            decoration: _decoration(
                              hint: 'Re-enter your password',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },

                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF7D7D8A),
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please confirm your password';
                              }

                              if (value !=
                                  _passwordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,height: 52,
                            child: ElevatedButton(
                              onPressed:  _isLoading  ? null: _handleSignUp,
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                foregroundColor: Colors.white, elevation: 0,
                                shape:RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), ),
                              ),

                              child: _isLoading ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,  strokeWidth: 2,
                                      ),
                                    )
                                  : const Text( 'Create Account',
                                   style: TextStyle(fontFamily: 'Be Vietnam Pro', fontFamilyFallback: ['sans-serif' ],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 13),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [ Text( 'Already have an account? ',  style: _bodyStyle.copyWith(
                                    fontSize: 13.5,color: const Color(0xFF5F5F6B), ),
                                ),

                                TextButton(onPressed: () {
                                    Navigator.pushReplacement( context,MaterialPageRoute(
                                        builder: (context) => const LoginScreen(), ), );},

                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:  MaterialTapTargetSize .shrinkWrap,
                                    foregroundColor: SignUpScreen.accentColor,
                                  ),

                                  child: const Text( 'Log In',
                                    style: TextStyle( fontFamily: 'Be Vietnam Pro',
                                      fontFamilyFallback: [ 'sans-serif' ],
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700, ),
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }
}

class _SignupBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF5F5F7)
      ..style = PaintingStyle.fill;

    canvas.drawRect( Offset.zero & size, backgroundPaint,);

    final purplePaint = Paint()
      ..color = const Color.fromARGB(255, 223, 210, 247)
      ..style = PaintingStyle.fill;

    final purplePath = Path();
    purplePath.moveTo(size.width * 0.50,0,);

    purplePath.cubicTo(
      size.width * 0.80,
      size.height * 0.025,
      size.width * 0.84,
      size.height * 0.017,
      size.width,
      size.height * 0.10,
    );

    purplePath.lineTo( size.width, 0,);

    purplePath.close();

    canvas.drawPath(purplePath, purplePaint,);

    final orangePaint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.fill;

    final orangePath = Path();
    orangePath.moveTo(0, 0);

    orangePath.lineTo( size.width * 0.70, 0,);

    orangePath.cubicTo(
      size.width * 0.65,
      size.height * 0.040,
      size.width * 0.50,
      size.height * 0.075,
      size.width * 0.37,
      size.height * 0.09,
    );

    orangePath.cubicTo(
      size.width * 0.40,
      size.height * 0.11,
      size.width * 0.11,
      size.height * 0.08,0,
      size.height * 0.15,
    );

    orangePath.close();

    canvas.drawPath( orangePath, orangePaint,);

    final orangeCirclePaint = Paint()
      ..color = AppColors.accentOrange.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset( size.width * 0.90, size.height * 0.18, ),30,
      orangeCirclePaint,
    );

    final purpleCirclePaint = Paint()
      ..color = AppColors.primaryPurple.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.35, ),22,
      purpleCirclePaint,
    );

    final dotPaint = Paint()
      ..color = AppColors.accentOrange.withOpacity(0.20)
      ..style = PaintingStyle.fill;

    const double dotRadius = 3;

    canvas.drawCircle(
      Offset( size.width * 0.90, size.height * 0.28,),
      dotRadius,dotPaint,
    );

    canvas.drawCircle( Offset( size.width * 0.94, size.height * 0.31, ),
      dotRadius,dotPaint,
    );

    canvas.drawCircle(
      Offset( size.width * 0.87, size.height * 0.32,),
      dotRadius, dotPaint,
    );

    final bottomPaint = Paint()
      ..color =const Color.fromARGB(255, 223, 210, 247)
      ..style = PaintingStyle.fill;

    final bottomPath = Path();

    bottomPath.moveTo( 0, size.height,);
    bottomPath.lineTo(0, size.height * 0.93,);

    bottomPath.cubicTo(
      size.width * 0.18,
      size.height * 0.96,
      size.width * 0.36,
      size.height * 0.94,
      size.width * 0.53,
      size.height * 0.965,
    );

    bottomPath.cubicTo(
      size.width * 0.70,
      size.height * 0.99,
      size.width * 0.87,
      size.height * 0.94,
      size.width,
      size.height * 0.90,
    );

    bottomPath.lineTo( size.width, size.height,);
    bottomPath.close();

    canvas.drawPath( bottomPath, bottomPaint, );
  }

  @override
  bool shouldRepaint(
covariant _SignupBackgroundPainter oldDelegate,
  ) {
    return false;
  }
}