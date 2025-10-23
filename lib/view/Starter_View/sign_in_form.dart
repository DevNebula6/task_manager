import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_manager/Auth/AuthExceptions.dart';
import 'package:task_manager/Auth/Bloc/auth_bloc.dart';
import 'package:task_manager/Auth/Bloc/auth_event.dart';
import 'package:task_manager/Auth/Bloc/auth_state.dart';
import 'package:task_manager/utilities/Dialog/show_message.dart';


class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<StatefulWidget> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _obscurePassword = true;
  String _email = '';
  String _password = '';

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
       if (state is AuthStateLoggedOut) {
        if (state.exception!=null) {
          String message;
          if (state.exception is InvalidCredentialAuthException) {
            message = 'Invalid credentials';
          } else if (state.exception is IllegalArgumentException) {
            message = 'Invalid argument';
          } else if (state.exception is GoogleLoginFailureException) {
            message = 'Google login failed';
          } else if (state.exception is CancelledByUserAuthException) {
            message = 'Sign-in was cancelled';
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
    body: Container(
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
                  padding: const EdgeInsets.all(24.0),
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
                    children: [
                      const SizedBox(height: 16),
                        AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'Sign In',
                                  textStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                  speed: const Duration(milliseconds: 150),
                                  ),
                                  ],
                                totalRepeatCount: 1,
                              displayFullTextOnTap: true,
                          ),
                      const SizedBox(height: 16),
                      const Text(
                        'The secret of getting ahead is getting started. Embrace your journey with GRIND.',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(),
                      const SizedBox(height: 16),
                      const Text(
                        'Dream it. Wish it. GRIND it.',
                        style: TextStyle(
                          fontSize: 19,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(),
                      const SizedBox(height: 24),
                      _buildEmailField().animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(),
                      const SizedBox(height: 16),
                      _buildPasswordField().animate().fadeIn(delay: 400.ms, duration: 500.ms).slideX(),
                      const SizedBox(height: 16),
                      _buildSignInButton().animate().fadeIn(delay: 600.ms, duration: 500.ms).scale(),
                      const SizedBox(height: 1),
                      _buildForgotPasswordButton().animate().fadeIn(delay: 700.ms, duration: 500.ms),
                      const SizedBox(height: 16),
                       Text(
                        'Or sign in with google',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        ),
                      ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
                      const SizedBox(height: 10),
                      _buildSocialLoginButtons().animate().fadeIn(delay: 900.ms, duration: 500.ms).slideY(),
                      const SizedBox(height: 16),
                      _buildRegisterButton().animate().fadeIn(delay: 1000.ms, duration: 500.ms),
                    ],
                  ),
                ),
              ),
              ).animate().scale(delay: 200.ms, duration: 500.ms),
                      ),
                    ),
                  )
              ),
          ],
        )))
 )
 );
}

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email, color: Colors.green),
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (value) => _email = value ?? '',
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.green),
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        suffixIcon: IconButton(
          icon: Icon(
            !_obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
      onSaved: (value) => _password = value ?? '',
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton.icon(
      onPressed: _submitForm,
      icon: const Icon(Icons.arrow_forward_rounded, size: 30),
      label: const Text(
        'Sign In',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade700,
        minimumSize: const Size(double.infinity, 56),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          context.read<AuthBloc>().add(const AuthEventForgotPassword());
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () {
        context.read<AuthBloc>().add(const AuthEventNavigateToRegister());
      },
      child: const Text(
        'New user? Register here!',
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Poppins',
          color: Colors.purpleAccent,
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //sign-in logic here
      context.read<AuthBloc>().add(
            AuthEventLogIn(_email, _password),
          );
    }
  }
}


