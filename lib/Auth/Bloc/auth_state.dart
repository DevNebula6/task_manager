import 'package:flutter/foundation.dart' show immutable;
import 'package:equatable/equatable.dart';
import 'package:task_manager/Auth/auth_providers_user.dart';

enum AuthView {
  signIn,
  register,
  onboarding,
}

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required super.isLoading,
  });
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;
  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required super.isLoading,
  });
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  final Exception? exception;
  const AuthStateLoggedIn({
    required this.user,
    required super.isLoading,
    this.exception,
  });
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required super.isLoading});
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  final String? loadingText;
  final AuthView intendedView; // New field

  const AuthStateLoggedOut({
    required this.exception,
    required this.isLoading,
    this.loadingText ,
    this.intendedView = AuthView.signIn, // Default to sign in view
  }) : super(isLoading: false);

  @override
  List<Object?> get props => [exception, isLoading, intendedView];
}
