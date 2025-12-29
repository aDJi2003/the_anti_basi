import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_colors.dart';
import '../../../data/models/recipe.dart';
import 'recipe_controller.dart';

/// Preview screen for generated recipes - user selects which to save
class RecipePreviewScreen extends ConsumerWidget {
  const RecipePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(recipeControllerProvider);
    final controller = ref.read(recipeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _PreviewHeader(
              onBack: () {
                controller.clearGeneratedRecipes();
                context.pop();
              },
              selectedCount: state.selectedCount,
              totalCount: state.generatedRecipes.length,
            ),

            // Content
            Expanded(
              child: state.generatedRecipes.isEmpty
                  ? const _EmptyState()
                  : _PreviewContent(
                      recipes: state.generatedRecipes,
                      expiringItemNames: state.expiringItemNames,
                      onToggle: controller.toggleRecipeSelection,
                      onTap: (recipe) => controller.showPreviewDetail(context, recipe),
                    ),
            ),

            // Bottom bar
            _PreviewBottomBar(
              selectedCount: state.selectedCount,
              onSave: () => controller.saveSelectedRecipes(context),
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header with back button and selection count
class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.onBack,
    required this.selectedCount,
    required this.totalCount,
  });

  final VoidCallback onBack;
  final int selectedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated Recipes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$selectedCount of $totalCount selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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

/// Empty state when no recipes generated
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceLight : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray400,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Recipes Found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Could not find recipes for your available ingredients',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview content with recipes list
class _PreviewContent extends StatelessWidget {
  const _PreviewContent({
    required this.recipes,
    required this.expiringItemNames,
    required this.onToggle,
    required this.onTap,
  });

  final List<Recipe> recipes;
  final List<String> expiringItemNames;
  final void Function(String recipeId) onToggle;
  final void Function(Recipe recipe) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // AI Info banner - using blue
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.blue.withAlpha(26) : AppColors.blueLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.blue.withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI found ${recipes.length} recipes',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.blue.withAlpha(230) : AppColors.blue,
                          ),
                        ),
                        Text(
                          'Based on your fridge ingredients',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.blue.withAlpha(150) : AppColors.blue.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Expiring items warning - using orange
        if (expiringItemNames.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.orange.withAlpha(26) : AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.orange.withAlpha(51),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: AppColors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Priority: ${expiringItemNames.join(", ")} (expiring soon)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.orange.withAlpha(230) : AppColors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'SELECT RECIPES TO SAVE',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        // Recipe list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final recipe = recipes[index];
              return _GeneratedRecipeTile(
                recipe: recipe,
                onToggle: () => onToggle(recipe.id),
                onTap: () => onTap(recipe),
              );
            },
            childCount: recipes.length,
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

/// Recipe tile with checkbox for selection - using purple accent
class _GeneratedRecipeTile extends StatelessWidget {
  const _GeneratedRecipeTile({
    required this.recipe,
    required this.onToggle,
    required this.onTap,
  });

  final Recipe recipe;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: recipe.isSelected
                  ? AppColors.purple.withAlpha(128)
                  : theme.dividerColor,
              width: recipe.isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox - using purple
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: recipe.isSelected
                            ? AppColors.purple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: recipe.isSelected
                              ? AppColors.purple
                              : isDark ? AppColors.darkBorder : AppColors.gray300,
                          width: 2,
                        ),
                      ),
                      child: recipe.isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Recipe info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          recipe.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Cook time & difficulty
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.cookTimeDisplay,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: recipe.difficulty.color.withAlpha(26),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                recipe.difficulty.displayName,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: recipe.difficulty.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Using expiring items - using teal
                        if (recipe.usesExpiringItems.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Uses:',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                ),
                              ),
                              ...recipe.usesExpiringItems.map((item) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.teal.withAlpha(26) : AppColors.tealLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_rounded,
                                        size: 12,
                                        color: AppColors.teal,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        item,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: AppColors.teal,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.darkTextMuted : AppColors.gray400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom bar with save button - using purple
class _PreviewBottomBar extends StatelessWidget {
  const _PreviewBottomBar({
    required this.selectedCount,
    required this.onSave,
    required this.isLoading,
  });

  final int selectedCount;
  final VoidCallback onSave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasSelection = selectedCount > 0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 51 : 13),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selection info
          if (hasSelection)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.purple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$selectedCount recipe${selectedCount > 1 ? 's' : ''} selected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: hasSelection && !isLoading ? onSave : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bookmark_add_rounded),
              label: Text(
                isLoading
                    ? 'Saving...'
                    : hasSelection
                        ? 'Save Selected Recipes'
                        : 'Select Recipes to Save',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasSelection ? Colors.white : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    hasSelection ? AppColors.purple : (isDark ? AppColors.darkSurfaceLight : AppColors.gray200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
