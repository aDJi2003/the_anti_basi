import 'package:flutter/material.dart';
import '../../../../config/app_colors_extension.dart';

/// Banner prompting user to scan receipt for restocking
class RestockBanner extends StatelessWidget {
  const RestockBanner({
    super.key,
    this.onScanTap,
  });

  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              context.colors.textPrimary,
              context.colors.darkGrey,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restocked?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.surface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan receipt to auto-add items.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Scan button
            Material(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: onScanTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.document_scanner_outlined,
                    color: context.colors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
