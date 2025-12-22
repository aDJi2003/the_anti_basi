import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Bottom loader section with animated progress bar and secure text
/// Uses Material 3 motion guidelines with 1500ms duration
class SplashLoader extends StatefulWidget {
  const SplashLoader({super.key});

  @override
  State<SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<SplashLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Slide from left (-1) to right (1) and beyond
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(2, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom indeterminate progress bar
        SizedBox(
          width: 180,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: ColoredBox(
              color: AppColors.gray200,
              child: SlideTransition(
                position: _slideAnimation,
                child: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Secure environment text
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 12,
              color: AppColors.textMuted.withAlpha(153),
            ),
            const SizedBox(width: 6),
            Text(
              'SECURE ENVIRONMENT',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted.withAlpha(153),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
