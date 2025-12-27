import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

/// Main shell widget that wraps all main screens with persistent bottom nav
/// Similar to layout.tsx in Next.js / React Router outlet
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.child,
  });

  /// The current screen content (provided by ShellRoute)
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor from theme (scaffoldBackgroundColor)
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onNavTap(context, index),
        onAddTap: () => context.push(Routes.scan),
      ),
    );
  }

  /// Get current nav index based on current route
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith(Routes.home)) return 0;
    if (location.startsWith(Routes.inventory)) return 1;
    if (location.startsWith(Routes.recipes)) return 2;
    if (location.startsWith(Routes.profile)) return 3;

    return 0;
  }

  /// Handle navigation tap
  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.inventory);
        break;
      case 2:
        context.go(Routes.recipes);
        break;
      case 3:
        context.go(Routes.profile);
        break;
    }
  }
}
