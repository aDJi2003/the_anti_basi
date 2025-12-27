import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'data/providers/theme_provider.dart';
import 'data/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: TheAntiBasi(),
    ),
  );
}

class TheAntiBasi extends ConsumerStatefulWidget {
  const TheAntiBasi({super.key});

  @override
  ConsumerState<TheAntiBasi> createState() => _TheAntiBasiState();
}

class _TheAntiBasiState extends ConsumerState<TheAntiBasi> {
  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  void _initFCM() {
    final fcmService = ref.read(fcmServiceProvider);
    fcmService.initialize(_handleNotificationTap);
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final route = data['route'] as String?;
        
        // Example payload: {"route": "/inventory", "itemId": "123"}
        if (route != null) {
          // Use AppRouter context if available or navigate globally
          // Since we are outside the Router context here, using the global navigator key
          // or just letting the router handle it if we were inside.
          // However, GoRouter instance is static in AppRouter.
          AppRouter.router.push(route);
        } else {
          // Default to inventory for generic reminders
          AppRouter.router.go(Routes.inventory);
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
        AppRouter.router.go(Routes.inventory);
      }
    } else {
      AppRouter.router.go(Routes.inventory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    // Update system UI based on theme
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'The Anti-Basi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
