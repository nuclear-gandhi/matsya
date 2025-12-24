import 'package:flutter/material.dart';
import '../design/colors.dart';

/// Status indicator widget for permissions and status
enum StatusType {
  success,
  warning,
  error,
}

/// Status indicator widget
class StatusIndicator extends StatelessWidget {
  final StatusType type;
  final double size;

  const StatusIndicator({
    Key? key,
    required this.type,
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (type) {
      case StatusType.success:
        color = AppColors.success;
        icon = Icons.check;
        break;
      case StatusType.warning:
        color = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case StatusType.error:
        color = AppColors.error;
        icon = Icons.error_outline;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.6,
        color: AppColors.textPrimary,
      ),
    );
  }
}
