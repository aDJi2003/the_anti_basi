import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../data/models/scanned_item.dart';
import 'scan_results_controller.dart';
import 'widgets/results_header.dart';
import 'widgets/source_images.dart';
import 'widgets/scanned_item_tile.dart';
import 'widgets/results_bottom_bar.dart';

/// Screen displaying scan results with editable items
class ScanResultsScreen extends ConsumerStatefulWidget {
  const ScanResultsScreen({super.key, this.extra});

  final Map<String, dynamic>? extra;

  @override
  ConsumerState<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends ConsumerState<ScanResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize controller with data from navigation extras
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeController();
    });
  }

  void _initializeController() {
    final controller = ref.read(scanResultsControllerProvider.notifier);
    final extra = widget.extra;

    if (extra == null) {
      // No extras, initialize for manual entry
      controller.initializeForManualEntry();
      return;
    }

    final isManualEntry = extra['isManualEntry'] as bool? ?? false;
    if (isManualEntry) {
      controller.initializeForManualEntry();
      return;
    }

    // Get items from Gemini scan
    final items = extra['items'] as List<ScannedItem>? ?? [];
    final imagePath = extra['imagePath'] as String?;

    controller.initializeWithItems(items, imagePath: imagePath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(scanResultsControllerProvider);
    final controller = ref.read(scanResultsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            ResultsHeader(
              onBack: () => controller.goBack(context),
              onMore: () {
                // TODO: Show more options
              },
            ),

            // Content
            Expanded(
              child: state.isLoading
                  ? const _LoadingState()
                  : state.items.isEmpty
                      ? const _EmptyState()
                      : _ResultsContent(
                          state: state,
                          controller: controller,
                        ),
            ),

            // Bottom bar
            ResultsBottomBar(
              destination: state.destination,
              onDestinationTap: () => controller.changeDestination(context),
              onAddToInventory: () => controller.addToInventory(context),
              isLoading: state.isSaving,
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Analyzing items...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no items detected
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
                Icons.search_off_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray400,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Items Detected',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try taking another photo or add items manually',
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

/// Main results content
class _ResultsContent extends StatelessWidget {
  const _ResultsContent({
    required this.state,
    required this.controller,
  });

  final ScanResultsState state;
  final ScanResultsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // Source images section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SourceImages(
              images: state.sourceImages,
              onAddImage: () {
                // TODO: Add more images
              },
            ),
          ),
        ),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DETECTED ITEMS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '${state.selectedCount}/${state.items.length} selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Items list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = state.items[index];
              return Column(
                children: [
                  ScannedItemTile(
                    item: item,
                    onToggle: () => controller.toggleItem(item.id),
                    onQuantityChanged: (qty) =>
                        controller.updateQuantity(item.id, qty),
                    onUnitChanged: (unit) =>
                        controller.updateUnit(item.id, unit),
                    onDateTap: () =>
                        controller.updateExpiryDate(context, item.id),
                    onDelete: () => controller.deleteItem(item.id),
                  ),
                  if (index < state.items.length - 1)
                    Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                      color: isDark ? AppColors.darkDivider : AppColors.gray100,
                    ),
                ],
              );
            },
            childCount: state.items.length,
          ),
        ),

        // Add manual item button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _AddManualItemButton(
              onTap: () => controller.addManualItem(context),
            ),
          ),
        ),

        // Bottom padding for safe area
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }
}

/// Add manual item button
class _AddManualItemButton extends StatelessWidget {
  const _AddManualItemButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Add Item Manually',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
