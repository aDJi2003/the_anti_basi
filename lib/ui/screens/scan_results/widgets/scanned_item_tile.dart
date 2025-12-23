import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_colors.dart';
import '../../../../data/models/scanned_item.dart';

/// Individual scanned item tile with checkbox, qty, and date
class ScannedItemTile extends StatelessWidget {
  const ScannedItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onQuantityChanged,
    required this.onDateTap,
    required this.onDelete,
  });

  final ScannedItem item;
  final VoidCallback onToggle;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onDateTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpiringSoon = item.expiryDate != null &&
        item.expiryDate!.difference(DateTime.now()).inDays <= 3;

    return Opacity(
      opacity: item.isUnknown ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          item.isSelected ? AppColors.primary : AppColors.gray300,
                      width: 2,
                    ),
                  ),
                  child: item.isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.categoryBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.categoryIcon,
                color: item.categoryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and delete button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.gray400,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  // Qty and Date inputs (if not unknown)
                  if (!item.isUnknown) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Quantity input
                        _QuantityInput(
                          value: item.quantity,
                          onChanged: onQuantityChanged,
                        ),
                        const SizedBox(width: 8),

                        // Date input
                        Expanded(
                          child: _DateInput(
                            date: item.expiryDate,
                            isExpiringSoon: isExpiringSoon,
                            onTap: onDateTap,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Could not detect details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quantity input field
class _QuantityInput extends StatelessWidget {
  const _QuantityInput({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(
                text: value == value.toInt()
                    ? value.toInt().toString()
                    : value.toString(),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) onChanged(parsed);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text(
              'Qty',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Date input field
class _DateInput extends StatelessWidget {
  const _DateInput({
    this.date,
    this.isExpiringSoon = false,
    required this.onTap,
  });

  final DateTime? date;
  final bool isExpiringSoon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isExpiringSoon
        ? const Color(0xFFFEF2F2) // red-50
        : AppColors.gray50;
    final borderColor = isExpiringSoon
        ? const Color(0xFFFECACA) // red-200
        : AppColors.gray200;
    final iconColor = isExpiringSoon
        ? AppColors.error
        : date != null
            ? AppColors.warning
            : AppColors.textMuted;
    final textColor = isExpiringSoon ? AppColors.error : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              isExpiringSoon ? Icons.warning_rounded : Icons.event_rounded,
              color: iconColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _formatDate(date, isExpiringSoon),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date, bool isExpiringSoon) {
    if (date == null) return 'Set date';
    if (isExpiringSoon) return 'Expires Soon';

    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 7) return 'In $diff days';

    return DateFormat('MMM d, y').format(date);
  }
}
