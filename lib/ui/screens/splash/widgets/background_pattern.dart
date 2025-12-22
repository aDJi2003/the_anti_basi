import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// Background pattern with subtle food icons and center glow
class BackgroundPattern extends StatelessWidget {
  const BackgroundPattern({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox.expand(
      child: Stack(
        children: [
          // Center glow effect
          Positioned(
            top: size.height * 0.3,
            left: size.width * 0.5 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withAlpha(20), // 0.08 * 255 ≈ 20
                    AppColors.primary.withAlpha(5),  // 0.02 * 255 ≈ 5
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Food icons pattern
          Positioned.fill(
            child: Transform.rotate(
              angle: -0.26, // -15 degrees
              child: Opacity(
                opacity: 0.06,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 40,
                    crossAxisSpacing: 40,
                  ),
                  itemCount: 40,
                  itemBuilder: (context, index) {
                    return Icon(
                      _getPatternIcon(index),
                      size: 40,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPatternIcon(int index) {
    final icons = [
      Icons.eco_outlined,
      Icons.egg_outlined,
      Icons.water_drop_outlined,
      Icons.bakery_dining_outlined,
      Icons.restaurant_outlined,
    ];
    return icons[index % icons.length];
  }
}
