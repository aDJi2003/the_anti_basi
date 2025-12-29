import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../../core/date_utils.dart' as app_date;
import '../../../../data/models/inventory_item.dart';

/// Banner showing expiry status with visual indicators
class ExpiryStatusHeader extends StatelessWidget {
  const ExpiryStatusHeader({
    super.key,
    required this.item,
  });

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = app_date.DateUtils.daysUntilExpiry(item.expiryDate);
    final status = item.expiryStatus;

    final (bgColor, borderColor, iconColor, icon, message) = _getStatusConfig(
      status,
      days,
      context,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          // Animated icon container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
              );
            },
          ),
          const SizedBox(width: 16),

          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(status, days),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Days indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  days < 0 ? '${-days}' : days == 0 ? '0' : '$days',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                    height: 1,
                  ),
                ),
                Text(
                  days < 0 ? 'ago' : days == 1 ? 'day' : 'days',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color, IconData, String) _getStatusConfig(
    ExpiryStatus status,
    int days,
    BuildContext context,
  ) {
    switch (status) {
      case ExpiryStatus.expired:
        return (
          AppColors.errorLight,
          AppColors.error.withAlpha(50),
          AppColors.error,
          Icons.warning_amber_rounded,
          'This item has passed its expiry date',
        );
      case ExpiryStatus.expiringToday:
        return (
          AppColors.errorLight,
          AppColors.error.withAlpha(50),
          AppColors.error,
          Icons.schedule_rounded,
          'Use this item today or check if still good',
        );
      case ExpiryStatus.expiringSoon:
        return (
          AppColors.warningLight,
          AppColors.warning.withAlpha(50),
          AppColors.warning,
          Icons.timelapse_rounded,
          'Consider using this item soon',
        );
      case ExpiryStatus.fresh:
        return (
          AppColors.primaryLight,
          AppColors.primary.withAlpha(50),
          AppColors.primary,
          Icons.check_circle_outline_rounded,
          'This item is still fresh',
        );
    }
  }

  String _getStatusTitle(ExpiryStatus status, int days) {
    switch (status) {
      case ExpiryStatus.expired:
        return 'Expired';
      case ExpiryStatus.expiringToday:
        return 'Expires Today';
      case ExpiryStatus.expiringSoon:
        return 'Expiring Soon';
      case ExpiryStatus.fresh:
        return 'Fresh';
    }
  }
}
