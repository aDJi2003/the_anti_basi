import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../data/models/recipe.dart';

/// Instruction step tile for recipe detail
class InstructionStepTile extends StatelessWidget {
  const InstructionStepTile({
    super.key,
    required this.instruction,
    this.isLast = false,
  });

  final RecipeInstruction instruction;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${instruction.stepNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  instruction.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
