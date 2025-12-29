import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';
import '../../../../data/models/inventory_item.dart';
import '../item_detail_controller.dart';

/// Bottom sheet for editing item quantity
class QuantityEditorSheet extends ConsumerStatefulWidget {
  const QuantityEditorSheet({
    super.key,
    required this.item,
  });

  final InventoryItem item;

  @override
  ConsumerState<QuantityEditorSheet> createState() =>
      _QuantityEditorSheetState();
}

class _QuantityEditorSheetState extends ConsumerState<QuantityEditorSheet> {
  late TextEditingController _controller;
  late double _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
    _controller = TextEditingController(text: _formatQuantity(_quantity));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(itemDetailControllerProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
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
                      'Edit Quantity',
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

              // Quantity controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Decrease button
                      _QuantityButton(
                        icon: Icons.remove_rounded,
                        onPressed: _quantity > 0
                            ? () => _updateQuantity(_quantity - 1)
                            : null,
                      ),
                      const SizedBox(width: 24),

                      // Quantity input
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null && parsed >= 0) {
                              setState(() => _quantity = parsed);
                            }
                          },
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Unit label
                      Text(
                        widget.item.unit,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Increase button
                      _QuantityButton(
                        icon: Icons.add_rounded,
                        onPressed: () => _updateQuantity(_quantity + 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 8,
                  children: [
                    _QuickButton(
                      label: 'Half',
                      onPressed: () => _updateQuantity(_quantity / 2),
                    ),
                    _QuickButton(
                      label: 'Double',
                      onPressed: () => _updateQuantity(_quantity * 2),
                    ),
                    _QuickButton(
                      label: 'Reset',
                      onPressed: () =>
                          _updateQuantity(widget.item.quantity),
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
      ),
    );
  }

  void _updateQuantity(double newValue) {
    if (newValue < 0) newValue = 0;
    setState(() {
      _quantity = newValue;
      _controller.text = _formatQuantity(newValue);
    });
  }

  String _formatQuantity(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  Future<void> _save() async {
    final success = await ref
        .read(itemDetailControllerProvider.notifier)
        .updateQuantity(_quantity);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity updated'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

/// Circular quantity adjustment button
class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return Material(
      color: isDisabled
          ? context.colors.surfaceLight
          : AppColors.primary.withAlpha(20),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isDisabled ? context.colors.textMuted : AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Quick action chip button
class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: context.colors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: context.colors.surface,
      side: BorderSide(color: context.colors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
