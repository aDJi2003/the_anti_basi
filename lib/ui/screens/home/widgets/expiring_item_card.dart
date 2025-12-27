import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../../data/models/inventory_item.dart';
import 'package:intl/intl.dart';

/// Card displaying an expiring inventory item
class ExpiringItemCard extends StatelessWidget {
  const ExpiringItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final InventoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colors.border),
            boxShadow: [
              BoxShadow(
                color: context.colors.textPrimary.withAlpha(8),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category icon
              _CategoryIcon(category: item.category),
              const SizedBox(width: 12),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.category.displayName} • ${item.quantityDisplay}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.colors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // Expiry info
              _ExpiryBadge(item: item),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category icon in colored container
class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});

  final ItemCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: category.lightColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: category.color.withAlpha(51),
        ),
      ),
      child: Icon(
        category.icon,
        size: 18,
        color: category.color,
      ),
    );
  }
}

/// Expiry badge showing status and time
class _ExpiryBadge extends StatelessWidget {
  const _ExpiryBadge({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = item.expiryStatus;
    final days = item.daysUntilExpiry;

    final (badgeColor, badgeBgColor, badgeBorderColor, badgeText) = switch (status) {
      ExpiryStatus.expired => (
          AppColors.error,
          AppColors.errorLight,
          AppColors.error.withAlpha(51),
          'Expired',
        ),
      ExpiryStatus.expiringToday => (
          AppColors.error,
          AppColors.errorLight,
          AppColors.error.withAlpha(51),
          'Expires',
        ),
      ExpiryStatus.expiringSoon => (
          AppColors.warning,
          AppColors.warningLight,
          AppColors.warning.withAlpha(51),
          '$days Day${days > 1 ? 's' : ''} Left',
        ),
      ExpiryStatus.fresh => (
          AppColors.primary,
          AppColors.primaryLight,
          AppColors.primary.withAlpha(51),
          '$days Days',
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeBgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: badgeBorderColor),
          ),
          child: Text(
            badgeText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('h:mm a').format(item.expiryDate),
          style: theme.textTheme.labelSmall?.copyWith(
            color: context.colors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
