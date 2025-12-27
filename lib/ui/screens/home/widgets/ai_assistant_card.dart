import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_colors_extension.dart';

/// AI Kitchen Assistant card with input field
class AiAssistantCard extends StatelessWidget {
  const AiAssistantCard({
    super.key,
    this.controller,
    this.onSubmit,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.smart_toy_outlined,
                color: context.colors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Kitchen Assistant',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Input card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.colors.border),
              boxShadow: [
                BoxShadow(
                  color: context.colors.textPrimary.withAlpha(8),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chef AI: What are we cooking today?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _AiInputField(
                  controller: controller,
                  onSubmit: onSubmit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// AI input field with send button
class _AiInputField extends StatefulWidget {
  const _AiInputField({
    this.controller,
    this.onSubmit,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onSubmit;

  @override
  State<_AiInputField> createState() => _AiInputFieldState();
}

class _AiInputFieldState extends State<_AiInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: "Tell AI what's in your hand to get a recipe...",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textMuted,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSubmit(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: _handleSubmit,
                borderRadius: BorderRadius.circular(6),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
