import 'package:flutter/material.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../../data/models/inventory_item.dart';
import 'expiring_item_card.dart';

/// Section showing items expiring soon, grouped by day
class ExpiringSoonSection extends StatelessWidget {
  const ExpiringSoonSection({
    super.key,
    required this.items,
    this.onViewAll,
    this.onItemTap,
  });

  final List<InventoryItem> items;
  final VoidCallback? onViewAll;
  final void Function(InventoryItem)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group items by day
    final grouped = _groupByDay(items);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Expiring Soon',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'Full records',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items grouped by day
          if (items.isEmpty)
            _EmptyState()
          else
            ...grouped.entries.map((entry) {
              return _DayGroup(
                label: entry.key,
                items: entry.value,
                onItemTap: onItemTap,
              );
            }),
        ],
      ),
    );
  }

  Map<String, List<InventoryItem>> _groupByDay(List<InventoryItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final Map<String, List<InventoryItem>> grouped = {};

    for (final item in items) {
      final itemDate = DateTime(
        item.expiryDate.year,
        item.expiryDate.month,
        item.expiryDate.day,
      );

      String label;
      if (itemDate.isBefore(today)) {
        label = 'OVERDUE';
      } else if (itemDate.isAtSameMomentAs(today)) {
        label = 'TODAY';
      } else if (itemDate.isAtSameMomentAs(tomorrow)) {
        label = 'TOMORROW';
      } else {
        final diff = itemDate.difference(today).inDays;
        label = 'IN $diff DAYS';
      }

      grouped.putIfAbsent(label, () => []).add(item);
    }

    return grouped;
  }
}

/// Group of items for a specific day
class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.label,
    required this.items,
    this.onItemTap,
  });

  final String label;
  final List<InventoryItem> items;
  final void Function(InventoryItem)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: context.colors.textMuted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ExpiringItemCard(
              item: item,
              onTap: () => onItemTap?.call(item),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Empty state when no items
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 40,
            color: context.colors.primary.withAlpha(153),
          ),
          const SizedBox(height: 12),
          Text(
            'All good!',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No items expiring soon',
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
