import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_colors.dart';
import '../../../../core/date_utils.dart' as app_date;
import '../../../../data/models/scanned_item.dart';

/// Individual scanned item tile with checkbox, qty, unit, and date
class ScannedItemTile extends StatelessWidget {
  const ScannedItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onQuantityChanged,
    required this.onUnitChanged,
    required this.onDateTap,
    required this.onDelete,
  });

  final ScannedItem item;
  final VoidCallback onToggle;
  final ValueChanged<double> onQuantityChanged;
  final ValueChanged<String> onUnitChanged;
  final VoidCallback onDateTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isExpiringSoon = app_date.DateUtils.isExpiringSoon(item.expiryDate);

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
                      color: item.isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.gray300),
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
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.gray400,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  // Qty, Unit, and Date inputs (if not unknown)
                  if (!item.isUnknown) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Quantity input
                        _QuantityInput(
                          value: item.quantity,
                          onChanged: onQuantityChanged,
                        ),
                        const SizedBox(width: 6),

                        // Unit selector
                        _UnitSelector(
                          value: item.unit,
                          onChanged: onUnitChanged,
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
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
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
  const _QuantityInput({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 56,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceLight : AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray200,
        ),
      ),
      child: TextField(
        controller: TextEditingController(
          text: value == value.toInt()
              ? value.toInt().toString()
              : value.toString(),
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          isDense: true,
        ),
        onChanged: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) onChanged(parsed);
        },
      ),
    );
  }
}

/// Available units for selection
const List<String> _availableUnits = [
  'pcs',
  'kg',
  'g',
  'L',
  'mL',
  'bottles',
  'cans',
  'bags',
  'boxes',
  'packs',
];

/// Unit selector dropdown
class _UnitSelector extends StatelessWidget {
  const _UnitSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceLight : AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _availableUnits.contains(value) ? value : 'pcs',
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          dropdownColor: theme.cardColor,
          items: _availableUnits.map((unit) {
            return DropdownMenuItem<String>(value: unit, child: Text(unit));
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isExpiringSoon
        ? (isDark ? AppColors.error.withAlpha(26) : const Color(0xFFFEF2F2))
        : (isDark ? AppColors.darkSurfaceLight : AppColors.gray50);
    final borderColor = isExpiringSoon
        ? (isDark ? AppColors.error.withAlpha(77) : const Color(0xFFFECACA))
        : (isDark ? AppColors.darkBorder : AppColors.gray200);
    final iconColor = isExpiringSoon
        ? AppColors.error
        : date != null
        ? AppColors.warning
        : (isDark ? AppColors.darkTextMuted : AppColors.textMuted);
    final textColor = isExpiringSoon
        ? AppColors.error
        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);

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

    final days = app_date.DateUtils.daysUntilExpiry(date);

    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return 'In $days days';

    return DateFormat('MMM d, y').format(date);
  }
}
