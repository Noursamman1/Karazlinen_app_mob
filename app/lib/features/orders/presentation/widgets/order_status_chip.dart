import 'package:flutter/material.dart';

import 'package:karaz_linen_app/design_system/theme/app_colors.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({
    super.key,
    required this.label,
    required this.statusCode,
  });

  final String label;
  final String statusCode;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = switch (statusCode) {
      'complete' => AppColors.success,
      'processing' => AppColors.warning,
      _ => AppColors.mist,
    };

    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor.withValues(alpha: 0.15),
    );
  }
}
