import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
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
    final statusBgColor = _getStatusBgColor(item.expiryStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: statusColor,
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
                    item.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Qty: ${_formatQuantity(item.quantity)} ${item.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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
                    color: AppColors.textMuted,
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

  Color _getStatusBgColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return AppColors.errorLight;
      case ExpiryStatus.expiringToday:
        return AppColors.errorLight;
      case ExpiryStatus.expiringSoon:
        return AppColors.warningLight;
      case ExpiryStatus.fresh:
        return AppColors.primaryLight;
    }
  }

  IconData _getCategoryIcon(ItemCategory category) {
    switch (category) {
      case ItemCategory.dairy:
        return Icons.water_drop_outlined;
      case ItemCategory.protein:
        return Icons.restaurant_outlined;
      case ItemCategory.vegetable:
        return Icons.grass_outlined;
      case ItemCategory.fruit:
        return Icons.apple;
      case ItemCategory.grain:
        return Icons.bakery_dining_outlined;
      case ItemCategory.condiment:
        return Icons.local_dining_outlined;
      case ItemCategory.beverage:
        return Icons.local_cafe_outlined;
      case ItemCategory.other:
        return Icons.inventory_2_outlined;
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
    if (days == 0) return 'Today';
    if (days == 1) return '1 Day';
    return '$days Days';
  }
}
