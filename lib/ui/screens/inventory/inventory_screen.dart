import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors_extension.dart';
import '../../widgets/common/notification_button.dart';
import 'inventory_controller.dart';
import 'widgets/inventory_filter_chips.dart';
import 'widgets/inventory_header.dart';
import 'widgets/inventory_search_bar.dart';
import 'widgets/inventory_section.dart';
import 'widgets/restock_banner.dart';

/// Inventory screen - Shows all fridge items
/// Note: Bottom nav bar is handled by MainShell (like layout.tsx in React)
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);
    final controller = ref.read(inventoryControllerProvider.notifier);

    return SafeArea(
      bottom: false,
      child: state.isLoading
          ? const _LoadingState()
          : RefreshIndicator(
              onRefresh: controller.refresh,
              color: context.colors.primary,
              child: CustomScrollView(
                slivers: [
                  // Header
                  const SliverToBoxAdapter(
                    child: InventoryHeader(
                      title: 'Your Inventory',
                      trailing: NotificationButton(),
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
    );
  }
}

/// Loading state
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: context.colors.primary,
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
              color: context.colors.inputBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: context.colors.textMuted,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filter',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
