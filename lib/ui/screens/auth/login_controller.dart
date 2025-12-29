import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../config/routes.dart';

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

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

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

      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      
      final User? user = userCredential.user;

      if (user != null) {
        await _checkAndCreateUserInFirestore(user);
      }

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

  Future<void> _checkAndCreateUserInFirestore(User user) async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        await userDocRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'User',
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'preferences': {
            'dietaryRestrictions': [],
            'cookingSkill': 'beginner', 
            'notificationEnabled': true,
          }
        });
      }
    } catch (e) {
      debugPrint("Error creating user in Firestore: $e");
    }
  }

  void navigateToSignUp(BuildContext context) {
    context.go(Routes.signUp);
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
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(LoginController.new);