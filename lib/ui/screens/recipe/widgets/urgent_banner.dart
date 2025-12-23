import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Urgent banner showing expiring items that need to be used
class UrgentBanner extends StatelessWidget {
  const UrgentBanner({
    super.key,
    required this.message,
    this.onTap,
  });

  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgent label
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: Colors.white.withAlpha(230),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'URGENT',
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            const Text(
              'Cooking with what expires soon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            // Message
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withAlpha(230),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
