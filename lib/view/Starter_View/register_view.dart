import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/Auth/AuthExceptions.dart';
import 'package:task_manager/Auth/Bloc/auth_bloc.dart';
import 'package:task_manager/Auth/Bloc/auth_event.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_manager/Auth/Bloc/auth_state.dart';
import 'package:task_manager/utilities/Dialog/show_message.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubicEmphasized,
    );
    _animationController.forward();

    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = _calculatePasswordStrength(_passwordController.text);
    });
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length > 8) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    return strength;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc,AuthState>(
      listener: (context, state) {
       
       if (state is AuthStateLoggedOut) {
        if (state.exception!=null) {
          String message;
          if (state.exception is EmailAlreadyInUseAuthException) {
            message = 'Email is already in use';
          } else if (state.exception is IllegalArgumentException) {
            message = 'Invalid argument';
          } else if (state.exception is GoogleLoginFailureException) {
            message = 'Google login failed';
          } else if (state.exception is CancelledByUserAuthException) {
            message = 'Sign-in was cancelled';
          } else if (state.exception is FacebookSignInFailedAuthException) {
            message = 'An error occurred during Facebook sign-in';
          } else {
            message = 'An error occurred';
          }
        showMessage(
            message: message,
            context: context,
            icon: Icons.error,
            backgroundColor: Colors.red);
          }
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade800,
                    Colors.indigo.shade900,
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    //back button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        onPressed: (){
                          context.read<AuthBloc>().add(const AuthEventNavigateToOnboarding());
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          ),
                        ) 
                      ),
                    Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth > 600
                                ? constraints.maxWidth * 0.1
                                : 24,
                            vertical: 24,
                          ),
                          child: FadeTransition(
                            opacity: _animation,
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      AnimatedTextKit(
                                        animatedTexts: [
                                          TypewriterAnimatedText(
                                            'Create Account',
                                            textStyle: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                            speed:
                                                const Duration(milliseconds: 100),
                                          ),
                                        ],
                                        totalRepeatCount: 1,
                                        displayFullTextOnTap: true,
                                      ),
                                      const SizedBox(height: 48),
                                      _buildTextField(
                                        controller: _emailController,
                                        hintText: 'Email',
                                        prefixIcon: Icons.email,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                              .hasMatch(value)) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      )
                                          .animate()
                                          .fadeIn(delay: 300.ms, duration: 500.ms)
                                          .slideX(),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _passwordController,
                                        hintText: 'Password',
                                        prefixIcon: Icons.lock,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a password';
                                          }
                                          if (value.length < 8) {
                                            return 'Password must be at least 8 characters long';
                                          }
                                          return null;
                                        },
                                      )
                                          .animate()
                                          .fadeIn(delay: 400.ms, duration: 500.ms)
                                          .slideX(),
                                      const SizedBox(height: 8),
                                      _buildPasswordStrengthIndicator(),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _confirmPasswordController,
                                        hintText: 'Confirm Password',
                                        prefixIcon: Icons.lock_clock,
                                        obscureText: _obscureConfirmPassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureConfirmPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                        validator: (value) {
                                          if (value != _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      )
                                          .animate()
                                          .fadeIn(delay: 500.ms, duration: 500.ms)
                                          .slideX(),
                                      const SizedBox(height: 32),
                                      ElevatedButton(
                                        onPressed: _register,
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.indigo.shade700,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text(
                                          'Register',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      )
                                          .animate()
                                          .fadeIn(delay: 600.ms, duration: 500.ms)
                                          .scale(),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Or sign up with',
                                        style: TextStyle(color: Colors.grey,
                                          fontSize: 18,
                                          ),
                                        textAlign: TextAlign.center,
                                      )
                                          .animate()
                                          .fadeIn(delay: 700.ms, duration: 500.ms),
                                      const SizedBox(height: 16),
                                      _buildSocialLoginButtons().animate().fadeIn(delay: 900.ms, duration: 500.ms).slideY(),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () {
                                          context.read<AuthBloc>().add(
                                              const AuthEventNavigateToSignIn());
                                        },
                                        child: const Text(
                                          'Already have an account? Sign In',
                                          style: TextStyle(color: Colors.indigo),
                                        ),
                                      )
                                          .animate()
                                          .fadeIn(delay: 900.ms, duration: 500.ms),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().scale(delay: 200.ms, duration: 500.ms),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton("assets/icons/google.svg", () {
          // Google login logic
          context.read<AuthBloc>().add(const AuthEventGoogleSignIn());
        }),
      ],
    ).animate()
      .scale(delay: 900.ms, duration: 300.ms)
      .then()
      .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.4));
  }

  Widget _buildSocialButton(String asset, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        asset,
        height: 40,
        width: 40,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(prefixIcon, color: Colors.indigo),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _passwordStrength,
          backgroundColor: Colors.grey.shade300,
          color: _getPasswordStrengthColor(_passwordStrength),
        ).animate().fadeIn(delay: 450.ms, duration: 500.ms).shimmer(),
        const SizedBox(height: 4),
        Text(
          _getPasswordStrengthText(_passwordStrength),
          style: TextStyle(
            color: _getPasswordStrengthColor(_passwordStrength),
            fontSize: 12,
          ),
        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
      ],
    );
  }

  Color _getPasswordStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _getPasswordStrengthText(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.7) return 'Medium';
    return 'Strong';
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthEventRegister(
              _emailController.text,
              _passwordController.text,
            ),
          );
    }
  }
}
