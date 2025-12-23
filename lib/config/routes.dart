import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/inventory/inventory_screen.dart';
import '../ui/screens/main/main_shell.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/scan/scan_screen.dart';
import '../ui/screens/scan_results/scan_results_screen.dart';
import '../ui/screens/splash/splash_screen.dart';

/// Route names
class Routes {
  Routes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String scanResults = '/scan-results';
  static const String inventory = '/inventory';
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipe/:id';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// App router configuration
class AppRouter {
  AppRouter._();

  /// Navigator key for shell route
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes (outside shell)
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main app routes (inside shell with persistent bottom nav)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: Routes.inventory,
            name: 'inventory',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InventoryScreen(),
            ),
          ),
          // TODO: Add recipes route
          GoRoute(
            path: Routes.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Routes outside shell (full screen overlays)
      GoRoute(
        path: Routes.scan,
        name: 'scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: Routes.scanResults,
        name: 'scanResults',
        builder: (context, state) => const ScanResultsScreen(),
      ),
      // TODO: Add settings route
    ],
  );
}
