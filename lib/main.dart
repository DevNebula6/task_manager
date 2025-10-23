import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_manager/Auth/Bloc/auth_bloc.dart';
import 'package:task_manager/Auth/Bloc/auth_event.dart';
import 'package:task_manager/Auth/Bloc/auth_state.dart';
import 'package:task_manager/Auth/auth_repository.dart';
import 'package:task_manager/Auth/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/Auth/firebase_auth_provider.dart';
import 'package:task_manager/utilities/Loading/loading_screen.dart';
import 'package:task_manager/view/HomeScreen/home.dart';
import 'package:task_manager/view/Starter_View/email_verification.dart';
import 'package:task_manager/view/Starter_View/forgot_password_view.dart';
import 'package:task_manager/view/Starter_View/onboarding_screen_view.dart';
import 'package:task_manager/view/Starter_View/register_view.dart';
import 'package:task_manager/view/Starter_View/sign_in_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initialize();

  final firebaseAuth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  final authRepository = AuthRepository(
    firebaseAuth: firebaseAuth,
    googleSignIn: googleSignIn,
  );
  final authProvider = FirebaseAuthProvider();

  runApp(
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        authProvider,
        authRepository: authRepository,
      )..add(const AuthEventInitialise()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return 
        MaterialApp(
          title: 'GRIND',
          home: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.isLoading) {
                LoadingScreen().show(
                  context: context,
                  text: state.loadingText ?? 'Please wait a moment',
                );
              } else {
                LoadingScreen().hide();
              }
            },
            builder: (context, state) => _buildHome(state),
          ),
          routes: 
          {
    
          },
        );
  }

  Widget _buildHome(AuthState state) {
    if (state is AuthStateLoggedIn) {
      return state.user.isEmailVerified ? const HomePage() : const EmailVerification();
    } else if (state is AuthStateNeedsVerification) {
      return const EmailVerification();
    } else if (state is AuthStateForgotPassword) {
      return const ForgotPasswordView();
    } else if (state is AuthStateLoggedOut) {
      switch (state.intendedView) {
        case AuthView.signIn:
          return const SignInView();
        case AuthView.register:
          return const RegisterView();
        case AuthView.onboarding:
        return const OnboardingScreenView();
      }
    } else if (state is AuthStateRegistering) {
      return const RegisterView();
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
