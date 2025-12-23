import 'package:flutter/material.dart';
import 'package:the_anti_basi/config/app_colors.dart';

class IngredientCard extends StatelessWidget {
  final String ingredientName;
  final String quantity;

  const IngredientCard({
    Key? key,
    required this.ingredientName,
    required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            ingredientName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            quantity,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mediumGrey,
                ),
          ),
        ],
      ),
    );
  }
}
