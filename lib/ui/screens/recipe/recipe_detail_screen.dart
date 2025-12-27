import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_colors.dart';
import '../../../data/models/recipe.dart';
import '../../../data/models/recipe_ingredient_display.dart';
import 'recipe_controller.dart';
import 'widgets/ingredient_list_tile.dart';
import 'widgets/instruction_step_tile.dart';
import 'widgets/pro_tip_card.dart';

/// Recipe detail screen with collapsible header and dynamic ingredient validation
class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recipeControllerProvider);

    // Find recipe by id in savedRecipes or generatedRecipes
    Recipe? recipe = state.savedRecipes.where((r) => r.id == recipeId).firstOrNull;
    recipe ??= state.generatedRecipes.where((r) => r.id == recipeId).firstOrNull;
    recipe ??= state.selectedRecipe;

    if (recipe == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        body: const Center(
          child: Text('Recipe not found'),
        ),
      );
    }

    // Get validated ingredients
    final validatedIngredients = RecipeValidator.validateIngredients(
      recipe,
      state.inventory,
    );
    final summary = RecipeValidator.getSummary(validatedIngredients);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Collapsible header
          SliverAppBar(
            expandedHeight: 260,
            collapsedHeight: 80,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: LayoutBuilder(
                builder: (context, constraints) {
                  final expandRatio = ((constraints.maxHeight - 80) / (260 - 80))
                      .clamp(0.0, 1.0);
                  final isCollapsed = expandRatio < 0.3;
                  final isDark = Theme.of(context).brightness == Brightness.dark;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isCollapsed ? 1.0 : 0.0,
                    child: Text(
                      recipe!.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
              background: _ExpandedHeader(recipe: recipe),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Warning banner if issues
                  if (summary.unavailable > 0)
                    _WarningBanner(summary: summary),

                  // Ingredients section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _SectionHeader(
                      title: 'Ingredients',
                      trailing: _IngredientSummaryChip(summary: summary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: validatedIngredients.map((ingredient) {
                        return IngredientListTile(ingredient: ingredient);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _SectionHeader(title: 'Instructions'),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: recipe.instructions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final instruction = entry.value;
                        return InstructionStepTile(
                          instruction: instruction,
                          isLast: index == recipe!.instructions.length - 1,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pro tip
                  if (recipe.proTip != null && recipe.proTip!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProTipCard(tip: recipe.proTip!),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Start cooking button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _StartCookingButton(
                      canCook: summary.canCook,
                      expiredCount: summary.expired,
                      missingCount: summary.missing,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Warning banner for ingredient issues
class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.summary});

  final IngredientSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasExpired = summary.expired > 0;
    final hasMissing = summary.missing > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasExpired
              ? AppColors.error.withAlpha(26)
              : AppColors.warning.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasExpired
                ? AppColors.error.withAlpha(51)
                : AppColors.warning.withAlpha(51),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasExpired ? Icons.error_rounded : Icons.warning_rounded,
              color: hasExpired ? AppColors.error : AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attention',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: hasExpired ? AppColors.error : AppColors.warning,
                    ),
                  ),
                  Text(
                    _buildMessage(hasExpired, hasMissing, summary),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hasExpired
                          ? AppColors.error.withAlpha(204)
                          : AppColors.warning.withAlpha(204),
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

  String _buildMessage(bool hasExpired, bool hasMissing, IngredientSummary summary) {
    final parts = <String>[];
    if (hasExpired) parts.add('${summary.expired} expired');
    if (hasMissing) parts.add('${summary.missing} missing');
    return parts.join(' • ');
  }
}

/// Expanded header content
class _ExpandedHeader extends StatelessWidget {
  const _ExpandedHeader({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 56),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recipe icon in circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 12),
            // Recipe title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                recipe.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (recipe.description != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  recipe.description!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Info chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoChip(
                  icon: Icons.schedule_outlined,
                  label: recipe.cookTimeDisplay,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: recipe.difficulty.icon,
                  label: recipe.difficulty.displayName,
                  color: recipe.difficulty.color,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.people_outline_rounded,
                  label: recipe.servingsDisplay,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Info chip widget
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chipColor = color ?? (isDark ? AppColors.darkTextMuted : AppColors.textMuted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ingredient summary chip
class _IngredientSummaryChip extends StatelessWidget {
  const _IngredientSummaryChip({required this.summary});

  final IngredientSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = summary.canCook ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${summary.available}/${summary.total} available',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Start cooking button with state awareness
class _StartCookingButton extends StatelessWidget {
  const _StartCookingButton({
    required this.canCook,
    required this.expiredCount,
    required this.missingCount,
  });

  final bool canCook;
  final int expiredCount;
  final int missingCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                canCook
                    ? 'Happy cooking!'
                    : 'Some ingredients are missing',
              ),
              backgroundColor: canCook ? AppColors.success : AppColors.warning,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
        icon: Icon(
          canCook ? Icons.restaurant_menu_rounded : Icons.warning_rounded,
          color: Colors.white,
        ),
        label: Text(
          canCook
              ? 'Start Cooking'
              : 'Start Cooking (${expiredCount + missingCount} missing)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: canCook ? AppColors.primary : AppColors.warning,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
