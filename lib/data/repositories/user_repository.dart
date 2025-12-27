import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_profile.dart';

/// Repository for user profile Firestore operations
class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Get users collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('users');
  }

  /// Get current user's document reference
  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final userId = _userId;
    if (userId == null) return null;
    return _usersCollection.doc(userId);
  }

  // ============ READ OPERATIONS ============

  /// Get current user profile
  Future<UserProfile?> getCurrentUser() async {
    final userId = _userId;
    debugPrint('[UserRepo] getCurrentUser - userId: $userId');

    if (userId == null) {
      debugPrint('[UserRepo] ERROR: User not authenticated');
      return null;
    }

    try {
      final doc = await _usersCollection.doc(userId).get();

      if (!doc.exists) {
        debugPrint('[UserRepo] User document does not exist');
        // Create a basic profile from Firebase Auth data
        return _createProfileFromAuth();
      }

      debugPrint('[UserRepo] Got user document: ${doc.data()}');
      return UserProfile.fromFirestore(doc);
    } catch (e) {
      debugPrint('[UserRepo] ERROR fetching user: $e');
      return _createProfileFromAuth();
    }
  }

  /// Create a basic profile from Firebase Auth
  UserProfile? _createProfileFromAuth() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
      email: user.email ?? '',
      photoURL: user.photoURL,
      createdAt: user.metadata.creationTime,
    );
  }

  /// Stream current user profile (real-time updates)
  Stream<UserProfile?> watchCurrentUser() {
    final userId = _userId;
    if (userId == null) {
      return Stream.value(null);
    }

    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return _createProfileFromAuth();
      return UserProfile.fromFirestore(doc);
    });
  }

  // ============ WRITE OPERATIONS ============

  /// Upload profile image and return download URL
  Future<String> uploadProfileImage(File imageFile) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Store in profiles_images folder with userId as filename
      // This automatically overwrites (deletes) any existing file with the same name
      final ref = _storage.ref().child('profile_images/$userId.jpg');

      // Upload file
      final uploadTask = await ref.putFile(imageFile);

      // Get download URL
      final downloadURL = await uploadTask.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      debugPrint('[UserRepo] ERROR uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Create or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _usersCollection
          .doc(profile.uid)
          .set(profile.toFirestore(), SetOptions(merge: true));
      debugPrint('[UserRepo] User profile saved');
    } catch (e) {
      debugPrint('[UserRepo] ERROR saving user profile: $e');
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    final doc = _userDoc;
    if (doc == null) throw Exception('User not authenticated');

    try {
      await doc.update({'displayName': displayName});

      // Also update Firebase Auth
      await _auth.currentUser?.updateDisplayName(displayName);
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  /// Update photo URL
  Future<void> updatePhotoURL(String photoURL) async {
    final doc = _userDoc;
    if (doc == null) throw Exception('User not authenticated');

    try {
      await doc.update({'photoURL': photoURL});

      // Also update Firebase Auth
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      throw Exception('Failed to update photo: $e');
    }
  }

  /// Update user preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    final doc = _userDoc;
    if (doc == null) throw Exception('User not authenticated');

    try {
      await doc.update({'preferences': preferences.toMap()});
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail() async {
    final email = _auth.currentUser?.email;
    if (email == null) throw Exception('No email associated with this account');

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Sign out from Firebase Auth and Google Sign-In
  Future<void> signOut() async {
    try {
      // Disconnect from Google (allows picking different account next time)
      final googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.disconnect();
        debugPrint('[UserRepo] Disconnected from Google');
      } catch (e) {
        // If disconnect fails, try signOut
        try {
          await googleSignIn.signOut();
          debugPrint('[UserRepo] Signed out from Google');
        } catch (_) {
          debugPrint('[UserRepo] Google was not signed in');
        }
      }

      // Sign out from Firebase Auth
      await _auth.signOut();
      debugPrint('[UserRepo] Signed out from Firebase Auth');
    } catch (e) {
      debugPrint('[UserRepo] ERROR during sign out: $e');
      // Still try to sign out from Firebase even if Google sign out fails
      await _auth.signOut();
    }
  }
}

// ============ PROVIDERS ============

/// Provider for user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Provider for current user profile
final currentUserProvider = FutureProvider<UserProfile?>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getCurrentUser();
});

/// Provider for current user stream (real-time)
final currentUserStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchCurrentUser();
});
