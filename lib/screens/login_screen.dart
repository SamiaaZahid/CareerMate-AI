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
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _credentialError;

  final TextEditingController _emailController =TextEditingController();
  final TextEditingController _passwordController =TextEditingController();

  TextStyle get _headlineStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontWeight: FontWeight.bold,fontSize: 28,
        color: Color(0xFF1F1F28),
      );

  TextStyle get _bodyStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],fontSize: 14,
        color: Color(0xFF6F6F7B),
      );

  TextStyle get _labelStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],
        fontSize: 14,fontWeight: FontWeight.w700,
        color: Color(0xFF1F1F28),
      );

  TextStyle get _fieldStyle => const TextStyle(
        fontFamily: 'Be Vietnam Pro',
        fontFamilyFallback: ['sans-serif'],fontSize: 15,
        color: Color(0xFF1F1F28),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginScreen.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginBackgroundPainter(), ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 440,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all( color: const Color(0xFFE8E1F5),),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 18,offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container( width: 96, height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE8E1F5), width: 6, ), ),
                              child: ClipOval(
                                child: Image.asset( 'assets/images/excelerate_logo.png',
                                  width: 96, height: 96, fit: BoxFit.cover, ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text( 'CareerMate AI', textAlign: TextAlign.center, style: _headlineStyle,),
                          const SizedBox(height: 8),
                          Text( 'Your personal AI career mentor.', textAlign: TextAlign.center, style: _bodyStyle, ),
                          const SizedBox(height: 28),
                          Text( 'Email Address',style: _labelStyle, ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType:  TextInputType.emailAddress,
                            style: _fieldStyle,
                            onChanged: (value) {
                              if (_credentialError != null) {
                                setState(() {
                                  _credentialError = null;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: _bodyStyle.copyWith( color: const Color(0xFF9A9AA6),),
                              prefixIcon: const Icon(
                                Icons.mail_outline, color: LoginScreen.primaryColor,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  const EdgeInsets.symmetric( horizontal: 16, vertical: 18,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide( color: Color(0xFFD8D8E3), ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide( color: LoginScreen.primaryColor, width: 1.4, ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(  color: Colors.red, width: 1.4, ),
                              ),
                              focusedErrorBorder:
                                  OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red, width: 1.4, ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||  value.trim().isEmpty) {
                                return 'Please enter your email';
                              }

                              final emailRegExp = RegExp( r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',);

                              if (!emailRegExp.hasMatch(
                                value.trim(),)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            }, ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text( 'Password', style: _labelStyle, ),
                              const Spacer(),
                              TextButton( onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: LoginScreen.accentColor,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize .shrinkWrap,
                                ),
                                child: const Text( 'Forgot?',
                                  style: TextStyle( fontFamily: 'Be Vietnam Pro',
                                    fontFamilyFallback: [ 'sans-serif'], fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: _fieldStyle,
                            forceErrorText: _credentialError,
                            onChanged: (value) {
                              if (_credentialError != null) {
                                setState(() {   _credentialError = null; });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: _bodyStyle.copyWith(color: const Color(0xFF9A9AA6), ),
                              prefixIcon: const Icon(
                                Icons.lock_outline, color: LoginScreen.primaryColor,),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {  _obscurePassword =  !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword  ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFF7D7D8A),
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  const EdgeInsets.symmetric(  horizontal: 16, vertical: 18,),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide( color: Color(0xFFD8D8E3), ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: LoginScreen.primaryColor, width: 1.4,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide( color: Colors.red, width: 1.4, ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius:  BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red, width: 1.4, ),
                              ),),

                            validator: (value) {
                              if (value == null ||  value.isEmpty) {
                                return 'Please enter your password';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity, height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null
                                  : () async {
                                      if (!mounted) return;
                                      if (!_formKey.currentState!.validate()) {
                                        return;}

                                      setState(() {
                                        _isLoading = true;
                                        _credentialError = null;
                                      });

                                      try {
                                        final email =  _emailController.text.trim();
                                        final password = _passwordController.text;
                                        final err =await AuthService.instance .login(
                                          email: email,
                                          password: password,
                                        );

                                        if (err != null) {
                                          setState(() { _credentialError = err; });
                                          return;
                                        }

                                        if (!context.mounted) {
                                          return;
                                        }

                                        Navigator.pushReplacement(
                                          context, MaterialPageRoute(builder: (context) => const HomeScreen(),), );
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context) .showSnackBar(
                                            const SnackBar( content: Text( 'Unable to sign in. Please try again.', ),
                                              backgroundColor: AppColors.primaryPurple, ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      }},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),),
                              ),
                              child: _isLoading? const SizedBox(
                                      width: 20, height: 20,
                                      child:CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2,),
                                    )
                                  : const Text( 'Login',style: TextStyle(
                                        fontFamily: 'Be Vietnam Pro',
                                        fontFamilyFallback: [  'sans-serif' ], fontSize: 16,
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
                              children: [ Text( "Don't have an account? ",
                                  style: _bodyStyle.copyWith(fontSize: 14, color: const Color(0xFF5F5F6B),), ),
                                TextButton( onPressed: () {
                                    Navigator.pushReplacement(context, MaterialPageRoute( builder: (context) =>const SignUpScreen(),), );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:MaterialTapTargetSize .shrinkWrap,
                                    foregroundColor:LoginScreen.accentColor,
                                  ),
                                  child: const Text('Sign Up',style: TextStyle( fontFamily: 'Be Vietnam Pro',
                                      fontFamilyFallback: [ 'sans-serif'], fontSize: 14, fontWeight: FontWeight.w700, ), ),
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
            ),),
        ],
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

class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF5F5F7)
      ..style = PaintingStyle.fill;

    canvas.drawRect( Offset.zero & size, backgroundPaint,);

    final purplePaint = Paint()
      ..color = const Color.fromARGB(255,223,210,247,)
      ..style = PaintingStyle.fill;

    final purplePath = Path();

    purplePath.moveTo(size.width * 0.50,0,);

    purplePath.cubicTo(
      size.width * 0.80,size.height * 0.025,
      size.width * 0.84,size.height * 0.017,
      size.width,size.height * 0.10,);

    purplePath.lineTo( size.width, 0,);
    purplePath.close();

    canvas.drawPath(purplePath, purplePaint,);

    final orangePaint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.fill;

    final orangePath = Path();
    orangePath.moveTo(0, 0);

    orangePath.lineTo( size.width * 0.70,0,);

    orangePath.cubicTo(
      size.width * 0.65,size.height * 0.040,
      size.width * 0.50,size.height * 0.075,
      size.width * 0.37,size.height * 0.09,);

    orangePath.cubicTo(
      size.width * 0.40,size.height * 0.11,
      size.width * 0.11,size.height * 0.08,0,
      size.height * 0.15,);

    orangePath.close();
    canvas.drawPath(orangePath,orangePaint,);

    final orangeCirclePaint = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle( Offset( size.width * 0.90,size.height * 0.18,),30,orangeCirclePaint,);

    final purpleCirclePaint = Paint()
      ..color =AppColors.primaryPurple.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    canvas.drawCircle( Offset(size.width * 0.08,size.height * 0.35,),22,purpleCirclePaint,);

    final dotPaint = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    const double dotRadius = 3;

    canvas.drawCircle(Offset(size.width * 0.90,size.height * 0.28,),dotRadius,dotPaint,);
    canvas.drawCircle(Offset( size.width * 0.94,size.height * 0.31,),dotRadius,dotPaint,);
    canvas.drawCircle(Offset(size.width * 0.87,size.height * 0.32,),dotRadius,dotPaint,);

    final bottomPaint = Paint()
      ..color = const Color.fromARGB(255,223,210,247,)
      ..style = PaintingStyle.fill;

    final bottomPath = Path();

    bottomPath.moveTo(0,size.height,);
    bottomPath.lineTo(0,size.height * 0.93,);

    bottomPath.cubicTo(
      size.width * 0.18,size.height * 0.96,
      size.width * 0.36,size.height * 0.94,
      size.width * 0.53,size.height * 0.965,);

    bottomPath.cubicTo(
      size.width * 0.70,size.height * 0.99,
      size.width * 0.87,size.height * 0.94,
      size.width,size.height * 0.90,);

    bottomPath.lineTo( size.width,size.height);
    bottomPath.close();
    canvas.drawPath( bottomPath, bottomPaint,);}

  @override
  bool shouldRepaint(covariant _LoginBackgroundPainter oldDelegate,) {
    return false;
  }
}