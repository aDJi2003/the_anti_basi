import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../widgets/common/app_button.dart';
import 'profile_controller.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

/// Profile screen - User account and settings
/// Note: Bottom nav bar is handled by MainShell (like layout.tsx in React)
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return SafeArea(
      bottom: false,
      child: state.isLoading
          ? const _LoadingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  // Header
                  const ProfileHeader(),
                  const SizedBox(height: 16),

                  // Avatar and user info
                  ProfileAvatar(
                    name: state.user?.name ?? 'User',
                    subtitle: state.user?.subtitle,
                    avatarUrl: state.user?.avatarUrl,
                    onAvatarTap: () => controller.onEditAvatar(context),
                  ),
                  const SizedBox(height: 32),

                  // Account Settings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SettingsSection(
                      title: 'Account Settings',
                      children: [
                        SettingsTile(
                          icon: Icons.badge_outlined,
                          label: 'Name',
                          value: state.user?.name,
                          onTap: () => controller.onEditName(context),
                        ),
                        SettingsTile(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email',
                          value: state.user?.email,
                          onTap: () => controller.onEditEmail(context),
                        ),
                        SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Password',
                          value: '••••••••',
                          onTap: () => controller.onChangePassword(context),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Preferences
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SettingsSection(
                      title: 'Preferences',
                      children: [
                        ToggleTile(
                          icon: Icons.dark_mode_outlined,
                          label: 'Dark Mode',
                          subtitle: 'Adjust app appearance',
                          value: state.isDarkMode,
                          onChanged: controller.toggleDarkMode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Log Out button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AppButton(
                      text: 'Log Out',
                      icon: Icons.logout_rounded,
                      onPressed: () => controller.onLogOut(context),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App version
                  Text(
                    state.appVersion,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Loading state
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}
