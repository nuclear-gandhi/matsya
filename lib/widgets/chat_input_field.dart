import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/spacing.dart';

/// Chat input field widget
class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final bool enabled;
  final String? hintText;

  const ChatInputField({
    Key? key,
    required this.controller,
    this.onSend,
    this.enabled = true,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.inputBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Input field
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: hintText ?? 'Message',
                  hintStyle: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onSubmitted: (_) => onSend?.call(),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
            // Send button
            if (onSend != null)
              IconButton(
                icon: const Icon(
                  Icons.send,
                  color: AppColors.accent,
                  size: 24,
                ),
                onPressed: enabled ? onSend : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

