import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/routes.dart';

/// SignUp screen state
class SignUpState {
  const SignUpState({
    this.isLoading = false,
    this.errorMessage,
    this.profileImagePath,
    this.isUploadingImage = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? profileImagePath;
  final bool isUploadingImage;

  SignUpState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? profileImagePath,
    bool? isUploadingImage,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    );
  }
}

/// SignUp controller - handles registration logic
class SignUpController extends Notifier<SignUpState> {
  static const int maxImageSizeBytes = 2 * 1024 * 1024; // 2 MB

  @override
  SignUpState build() => const SignUpState();

  /// Pick profile image from gallery
  Future<void> pickProfileImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile == null) return;

      // Check file size
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > maxImageSizeBytes) {
        if (context.mounted) {
          _showErrorSnackBar(
            context,
            'Image size must be under 2 MB. Please select a smaller image.',
          );
        }
        return;
      }

      state = state.copyWith(profileImagePath: pickedFile.path);
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to pick image: $e');
      }
    }
  }

  /// Take photo with camera
  Future<void> takePhoto(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile == null) return;

      // Check file size
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > maxImageSizeBytes) {
        if (context.mounted) {
          _showErrorSnackBar(
            context,
            'Image size must be under 2 MB. Please retake the photo.',
          );
        }
        return;
      }

      state = state.copyWith(profileImagePath: pickedFile.path);
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to take photo: $e');
      }
    }
  }

  /// Remove selected profile image
  void removeProfileImage() {
    state = SignUpState(
      isLoading: state.isLoading,
      errorMessage: state.errorMessage,
    );
  }

  /// Sign up with email, password, and name
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Create user with email and password
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to create account');
      }

      String? photoUrl;

      // Upload profile image if selected
      if (state.profileImagePath != null) {
        state = state.copyWith(isUploadingImage: true);
        photoUrl = await _uploadProfileImage(user.uid);
        state = state.copyWith(isUploadingImage: false);
      }

      // Update user profile with display name and photo
      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': name,
        'email': email,
        'photoURL': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'preferences': {
          'cookingSkill': 'beginner',
          'dietaryRestrictions': <String>[],
          'notificationEnabled': true,
        },
      });

      state = state.copyWith(isLoading: false);

      if (context.mounted) {
        _showSuccessSnackBar(context, 'Account created successfully! Welcome, $name');
        context.go(Routes.home);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';

      if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email is already registered.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      }

      state = state.copyWith(isLoading: false, errorMessage: message);
      if (context.mounted) _showErrorSnackBar(context, message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      if (context.mounted) _showErrorSnackBar(context, 'Error: $e');
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String?> _uploadProfileImage(String uid) async {
    if (state.profileImagePath == null) return null;

    try {
      final file = File(state.profileImagePath!);
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('[SignUpController] Failed to upload image: $e');
      return null;
    }
  }

  /// Navigate back to login
  void navigateToLogin(BuildContext context) {
    context.go(Routes.login);
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

final signUpControllerProvider =
    NotifierProvider<SignUpController, SignUpState>(SignUpController.new);
