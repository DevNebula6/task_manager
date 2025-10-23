import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/Auth/AuthExceptions.dart';
import 'package:task_manager/Auth/Bloc/auth_bloc.dart';
import 'package:task_manager/Auth/Bloc/auth_event.dart';
import 'package:task_manager/Auth/Bloc/auth_state.dart';
import 'package:task_manager/utilities/Dialog/show_message.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});
  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> with SingleTickerProviderStateMixin {
  static const String passwordResetEmailSent =
      'An email has been sent to your address. Click the link in the email to reset your password.';
  static const String sendPasswordResetEmail =
      'Enter your email address below to receive a password reset link.';
  String _messageText = sendPasswordResetEmail;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  late AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
        if (state is AuthStateForgotPassword) {
          setState(() => _isLoading = false);
          if (state.hasSentEmail) {
            setState(() => _messageText = passwordResetEmailSent);
            _showMessage('Password Reset Link Sent', Colors.green, Icons.check);
          }
          if (state.exception != null) {
            _showMessage(_getErrorMessage(state.exception!), Colors.red, Icons.error);
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue,
                      Colors.white, 
                      ],
                  ),
                ),
              ),
            ),
            // Animated background
            const Positioned.fill(
              child: AnimatedBackground(),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 20.0,
                    ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Lottie.asset(
                        'assets/animation/lottie/forgot_password_2.json',
                        height: 300,
                        repeat: true,
                        controller: _animationController,
                        onLoaded: (composition) {
                          _animationController.duration = composition.duration;
                          _animationController.forward();
                        },
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Password Reset',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          //shadows: [Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.3))],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildEmailField(),
                                const SizedBox(height: 25),
                                _sendPasswordResetLinkButton(),
                                const SizedBox(height: 20),
                                Text(
                                  _messageText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () => context.read<AuthBloc>().add(const AuthEventLogOut()),
                        icon: const Icon(Icons.arrow_back, color:  Color.fromARGB(255, 8, 29, 130)),
                        label:  Text('Back to Login', style: TextStyle(
                          color: Colors.indigo.shade700,
                          )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email, color: Colors.blue),
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[200],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
      style: const TextStyle(fontSize: 16),
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

  Widget _sendPasswordResetLinkButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 50,
      width: _isLoading ? 50 : double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_isLoading ? 25 : 15)),
          elevation: 5,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Send Reset Link', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      context.read<AuthBloc>().add(AuthEventForgotPassword(email: _email));
    }
  }

  void _showMessage(String message, Color backgroundColor, IconData icon) {
    showMessage(
      message: message,
      context: context,
      backgroundColor: backgroundColor,
      icon: icon,
    );
  }

  String _getErrorMessage(Exception exception) {
    if (exception is IllegalArgumentException) {
      return 'Email is not valid';
    } else if (exception is UserNotFoundAuthException) {
      return 'User not found';
    } else {
      return 'An error occurred';
    }
  }
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;

  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =Colors.blue[800]!
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, size.height * 0.9);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * (0.9 + 0.1 * sin(animationValue * 2 * 3.14159)),
      size.width * 0.5,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * (0.9 - 0.1 * sin(animationValue * 2 * 3.14159)),
      size.width,
      size.height * 0.9,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
