// AuthProvider is an abstract class that defines the methods that must be implemented by any class that wants to be an authentication provider.
// The AuthProvider class has the following methods:
// - initialize: This method is used to initialize the authentication provider.
// - currentUser: This method returns the current user.
// - login: This method is used to log in a user.
// - createUser: This method is used to create a new user.
// - logout: This method is used to log out a user.
// - sendEmailVerification: This method is used to send an email verification.
// - isEmailVerified: This method is used to check if the email is verified.
// - sendPasswordReset: This method is used to send a password reset email.
// The AuthProvider class is used by the AuthBloc to interact with the authentication provider.
// The AuthProvider class is implemented by the FirebaseAuthProvider class, which is used to interact with the Firebase authentication service.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class AuthProvider {
  
    Future<void> initialize();

    AuthUser? get currentUser;
    
    Future<AuthUser> login({
      required String email,
      required String password,
    });

    Future<AuthUser> createUser({
      required String email,
      required String password,  
    });
    Future<void> logout();
    Future<void> sendEmailVerification();
    Future<bool> isEmailVerified();
    Future<void> sendPasswordReset({required String toEmail});
    Future<AuthUser> signInWithGoogle();
}   

// Auth User 
@immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.isEmailVerified, 
    required this.email
    });

  factory AuthUser.fromFirebase(User user) => AuthUser(
    id: user.uid,
    email : user.email!,
    isEmailVerified : user.emailVerified,
    );
}
