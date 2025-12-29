import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_colors_extension.dart';
import '../../../core/date_utils.dart' as app_date;
import '../../../data/models/inventory_item.dart';
import 'item_detail_controller.dart';
import 'widgets/detail_info_card.dart';
import 'widgets/expiry_status_header.dart';
import 'widgets/quantity_editor_sheet.dart';

/// Item detail screen showing full information about an inventory item
class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.itemId,
    this.item,
  });

  final String itemId;
  final InventoryItem? item;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(itemDetailControllerProvider.notifier);
      if (widget.item != null) {
        controller.setItem(widget.item!);
      } else {
        controller.loadItem(widget.itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemDetailControllerProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorView(error: state.error!, onRetry: () {
                  ref.read(itemDetailControllerProvider.notifier)
                      .loadItem(widget.itemId);
                })
              : state.item != null
                  ? _ItemDetailBody(item: state.item!)
                  : const SizedBox.shrink(),
    );
  }
}

/// Main content body
class _ItemDetailBody extends ConsumerWidget {
  const _ItemDetailBody({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(itemDetailControllerProvider);

    return CustomScrollView(
      slivers: [
        // App bar with hero header
        _buildSliverAppBar(context, theme),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Expiry status banner
              ExpiryStatusHeader(item: item),
              const SizedBox(height: 24),

              // Quick info cards
              _buildInfoSection(context, theme),
              const SizedBox(height: 24),

              // Timeline section
              _buildTimelineSection(context, theme),
              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(context, ref, state),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: context.colors.surface,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.surface.withAlpha(230),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: context.colors.textPrimary,
            size: 20,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.category.color.withAlpha(40),
                item.category.color.withAlpha(20),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Category icon
                Hero(
                  tag: 'item-icon-${item.id}',
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: item.category.lightColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.category.color.withAlpha(100),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: item.category.color.withAlpha(50),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      item.category.icon,
                      color: item.category.color,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Item name
                Hero(
                  tag: 'item-name-${item.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      item.displayName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Category label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.category.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.category.displayName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: item.category.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DetailInfoCard(
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.blue,
                label: 'Quantity',
                value: '${_formatQuantity(item.quantity)} ${item.unit}',
                onTap: () => _showQuantityEditor(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailInfoCard(
                icon: Icons.category_outlined,
                iconColor: item.category.color,
                label: 'Category',
                value: item.category.displayName,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context, ThemeData theme) {
    final addedDate = DateFormat('MMM d, yyyy').format(item.addedAt);
    final addedTime = DateFormat('h:mm a').format(item.addedAt);
    final expiryDate = DateFormat('MMM d, yyyy').format(item.expiryDate);
    final daysUntil = app_date.DateUtils.daysUntilExpiry(item.expiryDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              // Added date
              _TimelineItem(
                icon: Icons.add_circle_outline_rounded,
                iconColor: AppColors.success,
                title: 'Added to inventory',
                subtitle: '$addedDate at $addedTime',
                isFirst: true,
              ),
              // Expiry date
              _TimelineItem(
                icon: daysUntil < 0
                    ? Icons.error_outline_rounded
                    : Icons.schedule_rounded,
                iconColor: _getExpiryColor(daysUntil),
                title: daysUntil < 0 ? 'Expired' : 'Expires',
                subtitle: expiryDate,
                trailing: _buildDaysChip(daysUntil, theme),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaysChip(int days, ThemeData theme) {
    final color = _getExpiryColor(days);
    final text = days < 0
        ? '${-days} days ago'
        : days == 0
            ? 'Today'
            : days == 1
                ? 'Tomorrow'
                : 'In $days days';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _getExpiryColor(int days) {
    if (days < 0) return AppColors.error;
    if (days == 0) return AppColors.error;
    if (days <= 3) return AppColors.warning;
    return AppColors.success;
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ItemDetailState state,
  ) {
    return Column(
      children: [
        // Primary action - Mark as consumed
        if (!item.isConsumed)
          FilledButton.icon(
            onPressed: state.isUpdating
                ? null
                : () => _confirmConsume(context, ref),
            icon: state.isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Mark as Consumed'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: AppColors.success,
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: context.colors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Item Consumed',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        // Secondary actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showQuantityEditor(context),
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Edit Qty'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: state.isDeleting
                    ? null
                    : () => _confirmDelete(context, ref),
                icon: state.isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showQuantityEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuantityEditorSheet(item: item),
    );
  }

  Future<void> _confirmConsume(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Consumed?'),
        content: Text(
          'This will set the quantity of "${item.displayName}" to 0.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(itemDetailControllerProvider.notifier)
          .markAsConsumed();
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item marked as consumed'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text(
          'Are you sure you want to delete "${item.displayName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(itemDetailControllerProvider.notifier)
          .deleteItem();
      if (success && context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.toInt()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(1);
  }
}

/// Timeline item widget
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 8,
                    color: context.colors.border,
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: context.colors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
