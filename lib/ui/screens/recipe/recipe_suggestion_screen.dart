import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import 'recipe_controller.dart';
import 'widgets/recipe_ai_input.dart';
import 'widgets/recipe_list_card.dart';
import 'widgets/recipe_screen_header.dart';
import 'widgets/urgent_banner.dart';

/// Recipe suggestion screen - Shows recipes based on inventory
/// Note: Bottom nav bar is handled by MainShell
class RecipeSuggestionScreen extends ConsumerStatefulWidget {
  const RecipeSuggestionScreen({super.key});

  @override
  ConsumerState<RecipeSuggestionScreen> createState() =>
      _RecipeSuggestionScreenState();
}

class _RecipeSuggestionScreenState
    extends ConsumerState<RecipeSuggestionScreen> {
  final _aiController = TextEditingController();

  @override
  void dispose() {
    _aiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  // Header with CTA
                  const SliverToBoxAdapter(
                    child: RecipeScreenHeader(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Urgent banner
                  if (state.urgentMessage != null)
                    SliverToBoxAdapter(
                      child: UrgentBanner(
                        message: state.urgentMessage!,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Section title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'SUGGESTED RECIPES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Recipe list
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final recipe = state.recipes[index];
                        return RecipeListCard(
                          recipe: recipe,
                          onTap: () => controller.navigateToDetail(context, recipe),
                          onBookmarkTap: () => controller.toggleBookmark(recipe.id),
                        );
                      },
                      childCount: state.recipes.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // AI Input field
                  SliverToBoxAdapter(
                    child: RecipeAiInput(
                      controller: _aiController,
                      onSubmit: (query) {
                        controller.onAiQuery(query, context);
                        _aiController.clear();
                      },
                      onVoiceTap: () {
                        // TODO: Implement voice input
                      },
                    ),
                  ),

                  // Bottom padding for nav bar
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
