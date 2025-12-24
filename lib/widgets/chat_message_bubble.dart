import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/app_theme.dart';

/// Chat message bubble widget
class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final EdgeInsetsGeometry? padding;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.userMessageBackground
              : AppColors.assistantMessageBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
