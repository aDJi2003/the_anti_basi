import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

/// Navigation item data
enum NavItem {
  home,
  inventory,
  add,
  recipes,
  profile;

  String get label {
    return switch (this) {
      NavItem.home => 'Home',
      NavItem.inventory => 'Inventory',
      NavItem.add => '',
      NavItem.recipes => 'Recipes',
      NavItem.profile => 'Profile',
    };
  }

  IconData get icon {
    return switch (this) {
      NavItem.home => Icons.home_rounded,
      NavItem.inventory => Icons.inventory_2_outlined,
      NavItem.add => Icons.add_rounded,
      NavItem.recipes => Icons.menu_book_outlined,
      NavItem.profile => Icons.person_outline_rounded,
    };
  }

  IconData get activeIcon {
    return switch (this) {
      NavItem.home => Icons.home_rounded,
      NavItem.inventory => Icons.inventory_2_rounded,
      NavItem.add => Icons.add_rounded,
      NavItem.recipes => Icons.menu_book_rounded,
      NavItem.profile => Icons.person_rounded,
    };
  }
}

/// Custom bottom navigation bar with elevated FAB
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onAddTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(242), // 95% opacity
        border: Border(
          top: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                item: NavItem.home,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                item: NavItem.inventory,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _AddButton(onTap: onAddTap),
              _NavItem(
                item: NavItem.recipes,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                item: NavItem.profile,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single navigation item
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? AppColors.primary : AppColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Elevated add button (FAB style)
class _AddButton extends StatelessWidget {
  const _AddButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 8,
        shadowColor: AppColors.primary.withAlpha(77),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withAlpha(128),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
