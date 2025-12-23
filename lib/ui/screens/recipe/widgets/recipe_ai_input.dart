import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';

/// AI input field for recipe queries
class RecipeAiInput extends StatelessWidget {
  const RecipeAiInput({
    super.key,
    required this.controller,
    this.onSubmit,
    this.onVoiceTap,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onVoiceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // AI sparkle icon
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
            ).createShader(bounds),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ask AI for a recipe with...',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmit,
            ),
          ),
          // Voice button
          IconButton(
            onPressed: onVoiceTap,
            icon: Icon(
              Icons.mic_outlined,
              color: AppColors.mediumGrey,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
