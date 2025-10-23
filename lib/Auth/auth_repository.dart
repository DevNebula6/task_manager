// auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  Future<void> logout() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<String?> getSignInMethod() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    
    final providerData = user.providerData;
    if (providerData.isEmpty) return null;

    switch (providerData[0].providerId) {
      case 'password':
        return 'email';
      case 'google.com':
        return 'google';
      case 'facebook.com':
        return 'facebook';
      default:
        return null;
    }
  }
}
