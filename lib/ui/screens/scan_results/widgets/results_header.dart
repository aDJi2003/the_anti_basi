import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Header for scan results screen
class ResultsHeader extends StatelessWidget {
  const ResultsHeader({
    super.key,
    required this.onBack,
    this.onMore,
  });

  final VoidCallback onBack;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),

          // Title
          Expanded(
            child: Text(
              'Scan Results',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // More button
          IconButton(
            onPressed: onMore,
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
