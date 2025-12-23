import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_colors.dart';
import '../../../config/routes.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';
import 'inventory_controller.dart';
import 'widgets/inventory_filter_chips.dart';
import 'widgets/inventory_header.dart';
import 'widgets/inventory_search_bar.dart';
import 'widgets/inventory_section.dart';
import 'widgets/restock_banner.dart';

/// Inventory screen - Shows all fridge items
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  final int _currentNavIndex = 1; // Inventory tab

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == _currentNavIndex) return;

    switch (index) {
      case 0: // Home
        context.go(Routes.home);
        break;
      case 1: // Inventory - already here
        break;
      case 2: // Recipes
        // TODO: Navigate to recipes
        break;
      case 3: // Profile
        // TODO: Navigate to profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);
    final controller = ref.read(inventoryControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: state.isLoading
            ? const _LoadingState()
            : RefreshIndicator(
                onRefresh: controller.refresh,
                color: AppColors.primary,
                child: CustomScrollView(
                  slivers: [
                    // Header
                    const SliverToBoxAdapter(
                      child: InventoryHeader(
                        title: 'Your Inventory',
                      ),
                    ),

                    // Search bar
                    SliverToBoxAdapter(
                      child: InventorySearchBar(
                        controller: _searchController,
                        onChanged: controller.onSearchChanged,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Filter chips
                    SliverToBoxAdapter(
                      child: InventoryFilterChips(
                        selectedFilter: state.selectedFilter,
                        onFilterChanged: controller.onFilterChanged,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Expiring soon section
                    if (state.expiringItems.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: InventorySection(
                          title: 'Expiring Soon',
                          items: state.expiringItems,
                          onViewAll: () {
                            controller
                                .onFilterChanged(InventoryFilter.expiringSoon);
                          },
                          onItemTap: (item) =>
                              controller.navigateToItemDetail(context, item),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],

                    // Fresh items section
                    if (state.freshItems.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: InventorySection(
                          title: 'Fresh Items',
                          items: state.freshItems,
                          onItemTap: (item) =>
                              controller.navigateToItemDetail(context, item),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],

                    // Empty state
                    if (state.filteredItems.isEmpty)
                      const SliverToBoxAdapter(
                        child: _EmptyState(),
                      ),

                    // Restock banner
                    SliverToBoxAdapter(
                      child: RestockBanner(
                        onScanTap: () => controller.navigateToScan(context),
                      ),
                    ),

                    // Bottom padding for nav bar
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => _handleNavigation(context, index),
        onAddTap: () => controller.navigateToScan(context),
      ),
    );
  }
}

/// Loading state
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

/// Empty state when no items match filter
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.gray400,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filter',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
