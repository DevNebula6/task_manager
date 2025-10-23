import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException, GoogleAuthProvider;
import 'package:task_manager/Auth/AuthExceptions.dart';
import 'package:task_manager/Auth/auth_providers_user.dart';
import 'package:task_manager/firebase_options.dart';

class FirebaseAuthProvider implements AuthProvider {
  AuthUser? _cachedUser ;
  Timer? _tokenRefreshTimer;

  @override
  Future<void> initialize() async { 
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createUser({required String email, required String password,})
     async {
      try { 
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, 
          password: password,
          );
        final user = currentUser;
        if(user != null){
          return user;
        } else {
           throw UserNotLoggedInAuthException();
        }
      } on FirebaseAuthException  catch(e) {
        switch (e.code) {
        case 'invalid-email':
        throw InvalidEmailAuthException();
      
        case 'weak-password':
          throw WeakPasswordAuthException();

        case 'email-already-in-use':
          throw EmailAlreadyInUseAuthException();

        default:
          throw GenericAuthException();
      }
      } catch (_) {
        throw GenericAuthException();
      }
  }

  @override
  AuthUser? get currentUser {
    if (_cachedUser != null) return _cachedUser;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _cachedUser = AuthUser.fromFirebase(user);
      return _cachedUser;
    }
    return null;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      
      // Start the Google sign-in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // If the user aborted the sign-in, googleUser will be null
      if (googleUser == null) {
        throw CancelledByUserAuthException();
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credentials with the tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        _cachedUser = AuthUser.fromFirebase(user);
        _startTokenRefreshTimer();
        return _cachedUser!;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on CancelledByUserAuthException {
      rethrow;
    } catch (e) {
      throw GoogleLoginFailureException();
    }
  }
    
  @override
  Future<AuthUser> login({required String email, required String password}) 
  async {
   try { 
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, 
      password: password,
      );
      final user = currentUser;
        if(user != null){
          _startTokenRefreshTimer();
          return user;
        } else {
           throw UserNotLoggedInAuthException();
        }
      } on FirebaseAuthException  catch(e) {
        switch (e.code) {
        case 'invalid-credential':
          throw InvalidCredentialAuthException();
        case 'channel-error':
          throw IllegalArgumentException();
        case 'invalid-email':
          throw InvalidEmailAuthException();
        default:
          throw GenericAuthException();
        } 
      } catch (_){
          throw GenericAuthException(); 
      }
  }

  @override
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null){
    await FirebaseAuth.instance.signOut();
    _cachedUser = null;
    _tokenRefreshTimer?.cancel();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
  
  @override
  Future<bool> isEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      return refreshedUser?.emailVerified ?? false;
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
  
  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
  
  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    try {
      return FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'user-not-found':
          throw UserNotFoundAuthException();
        case 'channel-error':
          throw IllegalArgumentException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
  }
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      FirebaseAuth.instance.currentUser?.getIdToken(true);
    });
  }
}
