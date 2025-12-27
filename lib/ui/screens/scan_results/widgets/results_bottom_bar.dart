import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Bottom bar for scan results with destination and add button
class ResultsBottomBar extends StatelessWidget {
  const ResultsBottomBar({
    super.key,
    required this.destination,
    required this.onDestinationTap,
    required this.onAddToInventory,
    this.isLoading = false,
  });

  final String destination;
  final VoidCallback onDestinationTap;
  final VoidCallback onAddToInventory;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withAlpha(242), // 95%
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.gray200),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Destination selector
            Expanded(
              child: GestureDetector(
                onTap: onDestinationTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Destination',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          destination,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.expand_more_rounded,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Add to inventory button
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              shadowColor: AppColors.primary.withAlpha(77),
              child: InkWell(
                onTap: isLoading ? null : onAddToInventory,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else ...[
                        Text(
                          'Add to Inventory',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
