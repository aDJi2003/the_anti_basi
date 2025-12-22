import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import 'splash_controller.dart';
import 'widgets/background_pattern.dart';
import 'widgets/splash_content.dart';
import 'widgets/splash_loader.dart';

/// Splash screen - Entry point of the app
/// UI only, logic handled by SplashController
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initSplash();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  void _initSplash() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashControllerProvider.notifier).init(context);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background pattern with food icons
          const BackgroundPattern(),

          // Main content - properly centered
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox.expand(
                child: Column(
                  children: [
                    // Top spacer - pushes content to center
                    const Spacer(),

                    // Center content (icon, title, tagline)
                    const SplashContent(),

                    // Bottom spacer - balances top spacer
                    const Spacer(),

                    // Bottom loader section
                    const Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: SplashLoader(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
