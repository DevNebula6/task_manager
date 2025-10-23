

import 'package:task_manager/Auth/auth_providers_user.dart';
import 'package:task_manager/Auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider
  {
  
  final AuthProvider provider;
  AuthService(this.provider);
  
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<void> initialize() => (provider.initialize());

  @override
  Future<AuthUser> createUser({
    required String email, 
    required String password,
    }) 
    => provider.createUser(email: email, password: password);
  
  @override
  AuthUser? get currentUser => provider.currentUser;
  
  @override
  Future<AuthUser> login({
    required String email, 
    required String password,
    }) => provider.login(email: email, password: password);
  
  @override
  Future<void> logout() => provider.logout();
  
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
  
  @override
  Future<bool> isEmailVerified() => provider.isEmailVerified();
  
  @override
  Future<void> sendPasswordReset({required String toEmail}) => provider.sendPasswordReset(toEmail: toEmail);
  
  @override
  Future<AuthUser> signInWithGoogle() => provider.signInWithGoogle();
  
}
