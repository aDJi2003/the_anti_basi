import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';

/// User profile data
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.subtitle,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final String? subtitle;
}

/// Profile screen state
class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.user,
    this.isDarkMode = false,
    this.appVersion = 'v2.4.0 (302)',
  });

  final bool isLoading;
  final UserProfile? user;
  final bool isDarkMode;
  final String appVersion;

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? user,
    bool? isDarkMode,
    String? appVersion,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      appVersion: appVersion ?? this.appVersion,
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

  /// Load user profile data
  Future<void> _loadProfile() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // Dummy user data
      const user = UserProfile(
        name: 'Budi',
        email: 'budi@student.edu',
        subtitle: 'Student • Food Saver',
      );

      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
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

  /// Change password
  void onChangePassword(BuildContext context) {
    _showSnackBar(context, 'Change password coming soon');
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
      // TODO: Clear auth state
      context.go(Routes.login);
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
