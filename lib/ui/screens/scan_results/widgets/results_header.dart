import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Header for scan results screen
class ResultsHeader extends StatelessWidget {
  const ResultsHeader({
    super.key,
    required this.onBack,
    this.onMore,
    this.moreButtonKey,
  });

  final VoidCallback onBack;
  final VoidCallback? onMore;
  final GlobalKey? moreButtonKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_rounded, color: textColor),
          ),

          // Title
          Expanded(
            child: Text(
              'Scan Results',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),

          // More button
          IconButton(
            key: moreButtonKey,
            onPressed: onMore,
            icon: Icon(Icons.more_horiz_rounded, color: textColor),
          ),
        ],
      ),
    );
  }
}
