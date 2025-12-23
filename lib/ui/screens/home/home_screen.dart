import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_anti_basi/config/app_colors.dart';
import 'package:the_anti_basi/ui/screens/recipe/widgets/recipe_suggestion.dart';
import 'home_controller.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/attention_banner.dart';
import 'widgets/expiring_soon_section.dart';
import 'widgets/fridge_card.dart';
import 'widgets/home_header.dart';

/// Home screen - Main dashboard
/// Note: Bottom nav bar is handled by MainShell (like layout.tsx in React)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _aiController = TextEditingController();

  @override
  void dispose() {
    _aiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

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
                  SliverToBoxAdapter(
                    child: HomeHeader(
                      userName: state.userName,
                      userAvatarUrl: state.userAvatarUrl,
                    ),
                  ),

                  // Fridge card
                  SliverToBoxAdapter(
                    child: FridgeCard(
                      itemCount: state.totalItems,
                      lastUpdated: state.lastUpdated,
                      onViewAll: () => controller.navigateToInventory(context),
                      fridgeImagePath: 'assets/images/fridge.jpg',
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Attention banner
                  SliverToBoxAdapter(
                    child: AttentionBanner(
                      itemCount: state.attentionCount,
                      onTap: () => controller.navigateToInventory(context),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // AI Assistant
                  SliverToBoxAdapter(
                    child: AiAssistantCard(
                      controller: _aiController,
                      onSubmit: (query) {
                        controller.onAiQuery(query, context);
                        _aiController.clear();
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Expiring soon section
                  SliverToBoxAdapter(
                    child: ExpiringSoonSection(
                      items: state.expiringItems,
                      onViewAll: () => controller.navigateToInventory(context),
                      onItemTap: (item) =>
                          controller.navigateToItemDetail(context, item),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Recipe Suggestions Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recipe Suggestions',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGrey,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to the full list of recipe suggestions
                              controller.navigateToRecipes(context);
                            },
                            child: Text(
                              'View All',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(
                    child: RecipeSuggestion(), // Use the newly created widget
                  ),

                  // Bottom padding for nav bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
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