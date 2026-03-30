import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/orders/application/orders_controller.dart';
import 'package:karaz_linen_app/features/orders/presentation/widgets/order_timeline_section.dart';

class OrderDetailsPage extends ConsumerWidget {
  const OrderDetailsPage({
    super.key,
    required this.orderNumber,
  });

  final String orderNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue detail = ref.watch(orderDetailProvider(orderNumber));
    return Scaffold(
      appBar: AppBar(title: Text('الطلب $orderNumber')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: detail.when(
          data: (dynamic value) {
            final order = value;
            return ListView(
              children: <Widget>[
                OrderTimelineSection(order: order),
                const SizedBox(height: AppSpacing.lg),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('المنتجات', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.md),
                      for (final dynamic item in order.items) ...<Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(child: Text(item.name)),
                            Text('x${item.quantity}'),
                            const SizedBox(width: AppSpacing.sm),
                            Text(item.total.formatted),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
                if (order.shippingAddress != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('عنوان الشحن', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.sm),
                        Text(order.shippingAddress!.streetLines.join('، ')),
                        Text(order.shippingAddress!.city),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ErrorStateCard(
            message: 'تعذر تحميل تفاصيل الطلب',
            onRetry: () => ref.invalidate(orderDetailProvider(orderNumber)),
          ),
        ),
      ),
    );
  }
}
