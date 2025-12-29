import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../../core/date_utils.dart' as app_date;
import '../../../../data/models/inventory_item.dart';
import '../item_detail_controller.dart';

/// Bottom sheet for editing item expiry date
class ExpiryDateEditorSheet extends ConsumerStatefulWidget {
  const ExpiryDateEditorSheet({
    super.key,
    required this.item,
  });

  final InventoryItem item;

  @override
  ConsumerState<ExpiryDateEditorSheet> createState() =>
      _ExpiryDateEditorSheetState();
}

class _ExpiryDateEditorSheetState extends ConsumerState<ExpiryDateEditorSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.item.expiryDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(itemDetailControllerProvider);
    final currentDays = app_date.DateUtils.daysUntilExpiry(widget.item.expiryDate);
    final newDays = app_date.DateUtils.daysUntilExpiry(_selectedDate);
    final hasChanged = !_isSameDay(_selectedDate, widget.item.expiryDate);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Edit Expiry Date',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Item info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.item.category.lightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.item.category.icon,
                      color: widget.item.category.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.item.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current vs New date comparison
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  children: [
                    // Current date row
                    _DateComparisonRow(
                      label: 'Current',
                      date: widget.item.expiryDate,
                      days: currentDays,
                      isHighlighted: false,
                    ),
                    if (hasChanged) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: context.colors.border)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.arrow_downward_rounded,
                                size: 20,
                                color: context.colors.textMuted,
                              ),
                            ),
                            Expanded(child: Divider(color: context.colors.border)),
                          ],
                        ),
                      ),
                      // New date row
                      _DateComparisonRow(
                        label: 'New',
                        date: _selectedDate,
                        days: newDays,
                        isHighlighted: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date picker button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Material(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withAlpha(100)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Date',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.colors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick date options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickDateChip(
                    label: 'Tomorrow',
                    onTap: () => _setQuickDate(1),
                    isSelected: newDays == 1,
                  ),
                  _QuickDateChip(
                    label: '+3 days',
                    onTap: () => _setQuickDate(3),
                    isSelected: newDays == 3,
                  ),
                  _QuickDateChip(
                    label: '+1 week',
                    onTap: () => _setQuickDate(7),
                    isSelected: newDays == 7,
                  ),
                  _QuickDateChip(
                    label: '+2 weeks',
                    onTap: () => _setQuickDate(14),
                    isSelected: newDays == 14,
                  ),
                  _QuickDateChip(
                    label: '+1 month',
                    onTap: () => _setQuickDate(30),
                    isSelected: newDays == 30,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton(
                onPressed: state.isUpdating ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: AppColors.primary,
                ),
                child: state.isUpdating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _setQuickDate(int daysFromNow) {
    setState(() {
      _selectedDate = DateTime.now().add(Duration(days: daysFromNow));
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_isSameDay(_selectedDate, widget.item.expiryDate)) {
      Navigator.pop(context);
      return;
    }

    final success = await ref
        .read(itemDetailControllerProvider.notifier)
        .updateExpiryDate(_selectedDate);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiry date updated'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

/// Row showing date comparison (current vs new)
class _DateComparisonRow extends StatelessWidget {
  const _DateComparisonRow({
    required this.label,
    required this.date,
    required this.days,
    required this.isHighlighted,
  });

  final String label;
  final DateTime date;
  final int days;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(days);

    return Row(
      children: [
        // Label chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.primary.withAlpha(20)
                : context.colors.border.withAlpha(100),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isHighlighted ? AppColors.primary : context.colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Date
        Expanded(
          child: Text(
            DateFormat('MMM d, yyyy').format(date),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isHighlighted ? context.colors.textPrimary : context.colors.textSecondary,
            ),
          ),
        ),
        // Days indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getDaysText(days),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(int days) {
    if (days < 0) return AppColors.error;
    if (days == 0) return AppColors.error;
    if (days <= 3) return AppColors.warning;
    return AppColors.success;
  }

  String _getDaysText(int days) {
    if (days < 0) return '${-days}d ago';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }
}

/// Quick date selection chip
class _QuickDateChip extends StatelessWidget {
  const _QuickDateChip({
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? AppColors.primary.withAlpha(20) : context.colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : context.colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primary : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
