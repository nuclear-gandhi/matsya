import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:matsya/design/app_theme.dart';
import '../design/colors.dart';
import '../design/spacing.dart';

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
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding:
            isUser
                ? const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                )
                : const EdgeInsets.symmetric(vertical: 10),
        decoration:
            isUser
                ? BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                )
                : null,
        child: Text(
          message,
          style: AppTheme.message.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
