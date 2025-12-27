import 'package:flutter/material.dart';
import '../../../../config/app_colors_extension.dart';

/// Search bar for inventory filtering
class InventorySearchBar extends StatelessWidget {
  const InventorySearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search inventory...',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.border),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.textMuted,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: context.colors.textMuted,
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
