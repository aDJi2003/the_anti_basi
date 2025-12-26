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
    final state = ref.watch(recipeControllerProvider);
    final controller = ref.read(recipeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                      onTap: (recipe) => controller.navigateToDetail(context, recipe),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasil Generate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$selectedCount/$totalCount resep dipilih',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.gray400,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Resep',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak dapat menemukan resep untuk bahan yang tersedia',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
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

    return CustomScrollView(
      slivers: [
        // AI Info banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI menemukan ${recipes.length} resep',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Berdasarkan bahan di kulkasmu',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary.withAlpha(179),
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

        // Expiring items warning
        if (expiringItemNames.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withAlpha(51),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Prioritas: ${expiringItemNames.join(", ")} (segera expired)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
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
              'PILIH RESEP UNTUK DISIMPAN',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
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

/// Recipe tile with checkbox for selection
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: recipe.isSelected
                  ? AppColors.primary.withAlpha(128)
                  : AppColors.gray200,
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
                  // Checkbox
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: recipe.isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: recipe.isSelected
                              ? AppColors.primary
                              : AppColors.gray300,
                          width: 2,
                        ),
                      ),
                      child: recipe.isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.white,
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Cook time & difficulty
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.cookTimeDisplay,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
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

                        // Using expiring items
                        if (recipe.usesExpiringItems.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Uses:',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              ...recipe.usesExpiringItems.map((item) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withAlpha(26),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_rounded,
                                        size: 12,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        item,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: AppColors.success,
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
                    color: AppColors.gray400,
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

/// Bottom bar with save button
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
    final hasSelection = selectedCount > 0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
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
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$selectedCount resep dipilih',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
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
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.bookmark_add_rounded),
              label: Text(
                isLoading
                    ? 'Menyimpan...'
                    : hasSelection
                        ? 'Simpan Resep Terpilih'
                        : 'Pilih Resep untuk Disimpan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasSelection ? AppColors.white : AppColors.textMuted,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    hasSelection ? AppColors.primary : AppColors.gray200,
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
