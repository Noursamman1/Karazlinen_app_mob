import 'package:flutter/material.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/orders/presentation/widgets/order_status_chip.dart';

class OrderTimelineSection extends StatelessWidget {
  const OrderTimelineSection({
    super.key,
    required this.order,
  });

  final OrderDetailView order;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('حالة الطلب', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          OrderStatusChip(label: order.statusLabel, statusCode: order.statusCode),
          const SizedBox(height: AppSpacing.sm),
          Text('رقم الطلب: ${order.orderNumber}'),
          Text('تاريخ الإنشاء: ${order.placedAt.toLocal()}'),
        ],
      ),
    );
  }
}
