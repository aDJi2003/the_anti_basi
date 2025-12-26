import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../data/models/recipe.dart';
import '../../../data/models/recipe_ingredient_display.dart';
import 'recipe_controller.dart';

/// Recipe screen - Shows saved recipes with generate option
class RecipeSuggestionScreen extends ConsumerWidget {
  const RecipeSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recipeControllerProvider);
    final controller = ref.read(recipeControllerProvider.notifier);

    return SafeArea(
      bottom: false,
      child: state.isLoading
          ? const _LoadingState()
          : RefreshIndicator(
              onRefresh: controller.refresh,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // Header
                  const SliverToBoxAdapter(child: _RecipeHeader()),

                  // Generate CTA Card
                  SliverToBoxAdapter(
                    child: _GenerateCtaCard(
                      expiringCount: state.expiringCount,
                      isGenerating: state.isGenerating,
                      onGenerate: () => controller.generateRecipes(context),
                    ),
                  ),

                  // Saved recipes section
                  if (state.hasSavedRecipes) ...[
                    // Section header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bookmark_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'RESEP TERSIMPAN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${state.savedRecipes.length} resep',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Saved recipes list
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final recipe = state.savedRecipes[index];
                          final summary = controller.getRecipeSummary(recipe);
                          return _SavedRecipeCard(
                            recipe: recipe,
                            summary: summary,
                            onTap: () => controller.navigateToDetail(context, recipe),
                            onDelete: () => _showDeleteDialog(context, controller, recipe),
                          );
                        },
                        childCount: state.savedRecipes.length,
                      ),
                    ),
                  ] else ...[
                    // Empty state
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptySavedState(),
                    ),
                  ],

                  // Bottom padding for nav bar
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    RecipeController controller,
    Recipe recipe,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Resep?'),
        content: Text('Yakin ingin menghapus "${recipe.name}"?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteRecipe(recipe.id, context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

/// Header with title
class _RecipeHeader extends StatelessWidget {
  const _RecipeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mau masak',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'apa hari ini?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
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

/// Generate recipes CTA card
class _GenerateCtaCard extends StatelessWidget {
  const _GenerateCtaCard({
    required this.expiringCount,
    required this.isGenerating,
    required this.onGenerate,
  });

  final int expiringCount;
  final bool isGenerating;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withBlue(200),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(77),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mau resep baru?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Generate resep dari bahan di kulkasmu',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(204),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Expiring items warning
            if (expiringCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$expiringCount bahan segera expired',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: isGenerating ? null : onGenerate,
                icon: isGenerating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.restaurant_menu_rounded),
                label: Text(
                  isGenerating ? 'Generating...' : 'Generate Recipes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

/// Saved recipe card with delete option
class _SavedRecipeCard extends StatelessWidget {
  const _SavedRecipeCard({
    required this.recipe,
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  final Recipe recipe;
  final IngredientSummary summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

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
            border: Border.all(color: AppColors.gray200),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.primary,
                      size: 24,
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
                            _buildDot(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
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

                        // Ingredient status badges
                        _IngredientStatusBadges(summary: summary),
                      ],
                    ),
                  ),

                  // Delete button
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.gray400,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '•',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Ingredient status badges (missing, expiring)
class _IngredientStatusBadges extends StatelessWidget {
  const _IngredientStatusBadges({required this.summary});

  final IngredientSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // In stock
        if (summary.available > 0)
          _buildBadge(
            icon: Icons.check_circle_rounded,
            text: '${summary.available}/${summary.total}',
            color: AppColors.success,
            theme: theme,
          ),

        // Expiring soon
        if (summary.expiringSoon > 0)
          _buildBadge(
            icon: Icons.warning_rounded,
            text: '${summary.expiringSoon} exp',
            color: AppColors.warning,
            theme: theme,
          ),

        // Missing
        if (summary.missing > 0)
          _buildBadge(
            icon: Icons.help_outline_rounded,
            text: '${summary.missing} missing',
            color: AppColors.gray500,
            theme: theme,
          ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no saved recipes
class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState();

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
                Icons.bookmark_border_rounded,
                color: AppColors.gray400,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Resep',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate resep dari bahan yang ada di kulkasmu untuk memulai',
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

/// Loading state widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}
