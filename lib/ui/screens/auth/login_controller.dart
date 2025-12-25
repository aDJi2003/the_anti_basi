import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../config/routes.dart';

/// Login screen state
class LoginState {
  const LoginState({
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isGoogleLoading;
  final String? errorMessage;

  LoginState copyWith({
    bool? isLoading,
    bool? isGoogleLoading,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Login controller - handles authentication logic
class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  /// Login with email and password
  Future<void> login(String email, String password, BuildContext context) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      state = state.copyWith(isLoading: false);
      
      if (context.mounted) {
        context.go(Routes.home);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      
      if (e.code == 'user-not-found') {
        message = 'Email tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah.';
      } else if (e.code == 'invalid-credential') {
        message = 'Email atau password salah.';
      }
      
      state = state.copyWith(isLoading: false, errorMessage: message);
      if (context.mounted) _showErrorSnackBar(context, message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      if (context.mounted) _showErrorSnackBar(context, 'Error: $e');
    }
  }

  /// Login with Google
  Future<void> loginWithGoogle(BuildContext context) async {
    state = state.copyWith(isGoogleLoading: true, errorMessage: null);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isGoogleLoading: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      state = state.copyWith(isGoogleLoading: false);

      if (context.mounted) {
        _showSuccessSnackBar(context, 'Welcome ${googleUser.displayName}!');
        context.go(Routes.home);
      }
    } catch (e) {
      state = state.copyWith(isGoogleLoading: false, errorMessage: e.toString());
      if (context.mounted) {
        _showErrorSnackBar(context, 'Google Sign In Error: $e');
      }
    }
  }

  void navigateToSignUp(BuildContext context) {
    _showInfoSnackBar(context, 'Fitur daftar belum dibuat.');
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(LoginController.new);