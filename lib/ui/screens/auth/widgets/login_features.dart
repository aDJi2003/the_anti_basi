import 'package:flutter/material.dart';
import '../../../widgets/common/feature_item.dart';

/// Feature list section for login screen
class LoginFeatures extends StatelessWidget {
  const LoginFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FeatureItem(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Quick Scan',
          description: 'Instantly add groceries via barcode.',
        ),
        SizedBox(height: 20),
        FeatureItem(
          icon: Icons.notifications_active_outlined,
          title: 'Expiration Reminders',
          description: 'Get notified before food spoils.',
        ),
        SizedBox(height: 20),
        FeatureItem(
          icon: Icons.restaurant_outlined,
          title: 'Smart Recipes',
          description: 'Cook meals with what you have.',
        ),
      ],
    );
  }
}
