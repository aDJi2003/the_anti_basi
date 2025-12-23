import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Filter type for inventory
enum InventoryFilter {
  all('All Items'),
  expiringSoon('Expiring Soon'),
  fresh('Fresh'),
  frozen('Frozen');

  const InventoryFilter(this.label);
  final String label;
}

/// Horizontal scrollable filter chips
class InventoryFilterChips extends StatelessWidget {
  const InventoryFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final InventoryFilter selectedFilter;
  final ValueChanged<InventoryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: InventoryFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = InventoryFilter.values[index];
          final isSelected = filter == selectedFilter;

          return _FilterChip(
            label: filter.label,
            isSelected: isSelected,
            onTap: () => onFilterChanged(filter),
          );
        },
      ),
    );
  }
}

/// Individual filter chip
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gray900 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.gray900 : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
