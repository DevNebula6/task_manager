import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/Auth/AuthExceptions.dart';
import 'package:task_manager/Auth/Bloc/auth_bloc.dart';
import 'package:task_manager/Auth/Bloc/auth_event.dart';
import 'package:task_manager/Auth/auth_service.dart';
import 'package:task_manager/utilities/Dialog/show_message.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  Timer? _emailVerificationTimer;
  late AnimationController _animationController;
  int _verificationAttempts = 0;
  DateTime? _lastVerificationAttempt;
  bool _isNetworkAvailable = true;
  bool _isCheckingVerification = false;
  int _currentBackoffSeconds = 5;

  static const Duration verificationTimeout = Duration(minutes: 15);
  static const int maxVerificationAttempts = 5;
  static const Duration cooldownPeriod = Duration(hours: 1);
  static const int maxBackoffSeconds = 15;

  @override
  void initState() {
    super.initState();
    _setupAnimationController();
    _setupNetworkListener();
    _sendVerificationEmail();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _emailVerificationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  void _setupNetworkListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final bool isConnected = results.isNotEmpty && results.first != ConnectivityResult.none;
      if (isConnected != _isNetworkAvailable) {
        setState(() {
          _isNetworkAvailable = isConnected;
        });
        if (isConnected) {
          _startEmailVerificationCheck();
        } else {
          _emailVerificationTimer?.cancel();
        }
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    if (_verificationAttempts >= maxVerificationAttempts &&
        _lastVerificationAttempt != null &&
        DateTime.now().difference(_lastVerificationAttempt!) < cooldownPeriod) {
      _showSnackBar('Too many attempts. Please try again later.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = AuthService.firebase().currentUser;
      if (user != null) {
        await AuthService.firebase().sendEmailVerification();
        _showSnackBar('Verification email sent! Please check your inbox.');
        _verificationAttempts++;
        _lastVerificationAttempt = DateTime.now();
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FailedToSendEmailVerificationException catch (e) {
      _showSnackBar('Failed to send email verification: $e');
    } on UserNotLoggedInAuthException {
      _showSnackBar('User not logged in. Please log in and try again.');
    } catch (e) {
      _showSnackBar('An unexpected error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startEmailVerificationCheck() {
    _emailVerificationTimer?.cancel();
    final startTime = DateTime.now();

    Future<void> checkVerification() async {
      if (!_isNetworkAvailable || _isCheckingVerification) return;

      if (DateTime.now().difference(startTime) > verificationTimeout) {
        _emailVerificationTimer?.cancel();
        _showSnackBar('Email verification timeout. Please try again later.');
        return;
      }

      _isCheckingVerification = true;

      try {
         final verified =await AuthService.firebase().isEmailVerified();
      if ( verified) {
          _emailVerificationTimer?.cancel();
          _showSnackBar('Email verified! You are now logged in.');
          BlocProvider.of<AuthBloc>(context).add(const AuthEventInitialise());
        } else {
          _showSnackBar('Email not yet verified. Please check your inbox and try again.');
        }
        _currentBackoffSeconds = min(_currentBackoffSeconds * 2, maxBackoffSeconds);
        _emailVerificationTimer = Timer(Duration(seconds: _currentBackoffSeconds), checkVerification);
      } catch (e) {
        _showSnackBar('Error checking email verification: $e');
        _currentBackoffSeconds = min(_currentBackoffSeconds * 2, maxBackoffSeconds);
        _emailVerificationTimer = Timer(Duration(seconds: _currentBackoffSeconds), checkVerification);
      } finally {
        _isCheckingVerification = false;
      }
    }

    _emailVerificationTimer = Timer(Duration(seconds: _currentBackoffSeconds), checkVerification);
  }

  Future<void> _checkVerificationNow() async {
    if (!_isNetworkAvailable) {
      _showSnackBar('No internet connection. Please check your network settings.');
      return;
    }

    if (_isCheckingVerification) {
      _showSnackBar('Verification check already in progress.');
      return;
    }

    setState(() {
      _isLoading = true;
      _isCheckingVerification = true;
    });

    try {
      final verified =await AuthService.firebase().isEmailVerified();
      if ( verified) {
          _emailVerificationTimer?.cancel();
          _showSnackBar('Email verified! You are now logged in.');
          BlocProvider.of<AuthBloc>(context).add(const AuthEventInitialise());
        } else {
          _showSnackBar('Email not yet verified. Please check your inbox and try again.');
        }
      
    } catch (e) {
      _showSnackBar('Error checking email verification: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isCheckingVerification = false;
      });
    }
  }

  void _showSnackBar(String message) {
    showMessage(
      context: context,
      message: message,
      margin: const EdgeInsets.all(10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService.firebase().currentUser?.email ?? 'your email';

    return Scaffold(
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedLottie(),
                    const SizedBox(height: 40),
                    _buildHeadingText(context),
                    const SizedBox(height: 20),
                    _buildEmailInfoText(context, email),
                    const SizedBox(height: 40),
                    _isLoading ? _buildLoadingIndicator() : _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildUseOtherEmailButton(),
                    if (!_isNetworkAvailable) _buildNoInternetWarning(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.blue[700]!, Colors.blue[300]!],
      ),
    );
  }

  Widget _buildAnimatedLottie() {
    return Lottie.asset(
      'assets/animation/lottie/Email.json',
      height: 250,
      controller: _animationController,
    );
  }

  Widget _buildHeadingText(BuildContext context) {
    return Text(
      'Verify Your Email',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildEmailInfoText(BuildContext context, String email) {
    return Column(
      children: [
        Text(
          'We\'ve sent a verification email to:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          email,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(color: Colors.white);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildCustomButton(
          onPressed: _sendVerificationEmail,
          text: 'Resend Verification Email',
        ),
        const SizedBox(height: 20),
        _buildCustomButton(
          onPressed: _checkVerificationNow,
          text: 'Check Verification Status',
        ),
      ],
    );
  }

  Widget _buildCustomButton({required VoidCallback onPressed, required String text}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildUseOtherEmailButton() {
    return TextButton(
      onPressed: () {
        context.read<AuthBloc>().add(const AuthEventLogOut());
      },
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child: const Text('Use different email', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildNoInternetWarning() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        'No internet connection. Please check your network settings.',
        style: TextStyle(color: Colors.red[300], fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
