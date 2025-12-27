import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../../data/models/inventory_item.dart';

/// Individual inventory item tile with expiry status
class InventoryItemTile extends StatelessWidget {
  const InventoryItemTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final InventoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(item.expiryStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.category.lightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.category.icon,
                color: item.category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Item info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName, 
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Qty: ${_formatQuantity(item.quantity)} ${item.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Days left
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getDaysText(item.daysUntilExpiry),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'left',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.colors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return AppColors.error;
      case ExpiryStatus.expiringToday:
        return AppColors.error;
      case ExpiryStatus.expiringSoon:
        return AppColors.warning;
      case ExpiryStatus.fresh:
        return AppColors.success;
    }
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(1);
  }

  String _getDaysText(int days) {
    if (days < 0) return 'Expired';

    int visualDays = days - 1;

    if (visualDays <= 0) return 'Today';
    
    if (visualDays == 1) return '1 Day';
    return '$visualDays Days';
  }
}