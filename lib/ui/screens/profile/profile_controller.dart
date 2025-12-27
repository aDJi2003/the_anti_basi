import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/routes.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/providers/auth_state_provider.dart';
import '../../../data/providers/theme_provider.dart';
import '../../../data/repositories/user_repository.dart';

/// Profile screen state
class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.user,
    this.isDarkMode = false,
    this.appVersion = 'v1.0.0',
    this.errorMessage,
  });

  final bool isLoading;
  final UserProfile? user;
  final bool isDarkMode;
  final String appVersion;
  final String? errorMessage;

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? user,
    bool? isDarkMode,
    String? appVersion,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      appVersion: appVersion ?? this.appVersion,
      errorMessage: errorMessage,
    );
  }
}

/// Profile controller - handles profile screen logic
class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    // Watch auth state - this causes rebuild when user changes
    ref.watch(currentUserIdProvider);
    _loadProfile();
    return const ProfileState(isLoading: true);
  }

  UserRepository get _userRepo => ref.read(userRepositoryProvider);

  /// Load user profile from Firestore
  Future<void> _loadProfile() async {
    try {
      debugPrint('[ProfileController] Fetching user profile...');
      final userProfile = await _userRepo.getCurrentUser();
      debugPrint('[ProfileController] Got user: ${userProfile?.displayName}');

      state = state.copyWith(isLoading: false, user: userProfile);
    } catch (e) {
      debugPrint('[ProfileController] ERROR: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Refresh profile data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _loadProfile();
  }

  /// Toggle dark mode - uses theme provider for persistence
  Future<void> toggleDarkMode(bool value) async {
    await ref.read(themeProvider.notifier).toggleDarkMode(value);
  }

  /// Edit name
  Future<void> onEditName(BuildContext context) async {
    final currentName = state.user?.displayName ?? '';
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter your name',
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      try {
        state = state.copyWith(isLoading: true);
        await _userRepo.updateDisplayName(newName);
        await _loadProfile(); // Reload to get fresh data
        if (context.mounted) {
          _showSnackBar(context, 'Name updated successfully');
        }
      } catch (e) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
        if (context.mounted) {
          _showSnackBar(context, 'Failed to update name');
        }
      } finally {
        // Ensure loading state is cleared if not already done by _loadProfile
        if (state.isLoading) state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Edit email
  void onEditEmail(BuildContext context) {
    _showSnackBar(context, 'Edit email coming soon');
  }

  /// Change password - sends password reset email
  Future<void> onChangePassword(BuildContext context) async {
    try {
      await _userRepo.sendPasswordResetEmail();
      if (context.mounted) {
        _showSnackBar(context, 'Password reset email sent');
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Failed to send reset email: $e');
      }
    }
  }

  /// Log out
  Future<void> onLogOut(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _userRepo.signOut();
      // Providers will be invalidated on next login, not here
      // (invalidating here can cause error state when user is null)
      if (context.mounted) {
        context.go(Routes.login);
      }
    }
  }

  /// Edit avatar
  Future<void> onEditAvatar(BuildContext context) async {
    final picker = ImagePicker();

    // Show modal bottom sheet to choose source (Camera or Gallery)
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512, // Resize to save bandwidth/storage
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image == null) return;

      state = state.copyWith(isLoading: true);

      // 1. Upload image
      final downloadUrl = await _userRepo.uploadProfileImage(File(image.path));

      // 2. Update profile with new URL
      await _userRepo.updatePhotoURL(downloadUrl);

      // 3. Reload profile
      await _loadProfile();

      if (context.mounted) {
        _showSnackBar(context, 'Profile photo updated');
      }
    } catch (e) {
      debugPrint('[ProfileController] Error updating avatar: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      if (context.mounted) {
        _showSnackBar(context, 'Failed to update profile photo');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Provider for profile controller
final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
