import 'package:go_router/go_router.dart';
import '../ui/screens/auth/login_screen.dart';
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
  static const String settings = '/settings';
}

/// App router configuration
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    routes: [
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
      // TODO: Add more routes as screens are created
    ],
  );
}
