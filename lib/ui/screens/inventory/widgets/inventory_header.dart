import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Inventory screen header with title and optional action
class InventoryHeader extends StatelessWidget {
  const InventoryHeader({
    super.key,
    this.title = 'Your Inventory',
    this.onBackTap,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBackTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back button (optional)
          if (onBackTap != null) ...[
            GestureDetector(
              onTap: onBackTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gray100),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.gray700,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Title
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Trailing widget (optional)
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
