import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../data/models/inventory_item.dart';
import 'inventory_item_tile.dart';

/// Section with title and list of inventory items
class InventorySection extends StatelessWidget {
  const InventorySection({
    super.key,
    required this.title,
    required this.items,
    this.onViewAll,
    this.onItemTap,
  });

  final String title;
  final List<InventoryItem> items;
  final VoidCallback? onViewAll;
  final void Function(InventoryItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View all',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return InventoryItemTile(
                item: item,
                onTap: () => onItemTap?.call(item),
              );
            },
          ),
        ],
      ),
    );
  }
}
