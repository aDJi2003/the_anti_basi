import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/user_repository.dart';

/// Profile screen state
class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.user,
    this.isDarkMode = false,
    this.appVersion = 'v2.4.0 (302)',
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

      state = state.copyWith(
        isLoading: false,
        user: userProfile,
      );
    } catch (e) {
      debugPrint('[ProfileController] ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh profile data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _loadProfile();
  }

  /// Toggle dark mode
  void toggleDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
    // TODO: Persist theme preference and update app theme
  }

  /// Edit name
  void onEditName(BuildContext context) {
    _showSnackBar(context, 'Edit name coming soon');
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _userRepo.signOut();
      if (context.mounted) {
        context.go(Routes.login);
      }
    }
  }

  /// Edit avatar
  void onEditAvatar(BuildContext context) {
    _showSnackBar(context, 'Edit avatar coming soon');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Provider for profile controller
final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
