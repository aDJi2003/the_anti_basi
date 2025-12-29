import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/inventory_item.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/signup_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/inventory/inventory_screen.dart';
import '../ui/screens/item_detail/item_detail_screen.dart';
import '../ui/screens/main/main_shell.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/scan/scan_screen.dart';
import '../ui/screens/scan_results/scan_results_screen.dart';
import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/recipe/recipe_suggestion_screen.dart';
import '../ui/screens/recipe/recipe_detail_screen.dart';
import '../ui/screens/recipe/recipe_preview_screen.dart';
import '../ui/screens/settings/settings_screen.dart';

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
  static const String itemDetail = '/inventory/item/:id';
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipes/detail/:id';
  static const String recipePreview = '/recipe-preview';
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
    initialLocation: Routes.splash,
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
      GoRoute(
        path: Routes.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main app routes (inside shell with persistent bottom nav)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: Routes.inventory,
            name: 'inventory',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InventoryScreen()),
          ),
          GoRoute(
            path: Routes.recipes,
            name: 'recipes',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RecipeSuggestionScreen()),
            routes: [
              GoRoute(
                path: ':id',
                name: 'recipeDetail',
                builder: (context, state) {
                  final recipeId = state.pathParameters['id'] ?? '';
                  return RecipeDetailScreen(recipeId: recipeId);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.profile,
            name: 'profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
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
        path: Routes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.scanResults,
        name: 'scanResults',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ScanResultsScreen(extra: extra);
        },
      ),
      GoRoute(
        path: Routes.recipePreview,
        name: 'recipePreview',
        builder: (context, state) => const RecipePreviewScreen(),
      ),
      GoRoute(
        path: Routes.itemDetail,
        name: 'itemDetail',
        builder: (context, state) {
          final itemId = state.pathParameters['id'] ?? '';
          final item = state.extra as InventoryItem?;
          return ItemDetailScreen(itemId: itemId, item: item);
        },
      ),
    ],
  );
}
