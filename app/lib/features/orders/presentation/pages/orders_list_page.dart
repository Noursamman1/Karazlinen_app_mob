import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/orders/application/orders_controller.dart';
import 'package:karaz_linen_app/features/orders/presentation/widgets/order_status_chip.dart';

class OrdersListPage extends ConsumerWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue orders = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: orders.when(
          data: (dynamic items) {
            final List typedItems = items as List;
            if (typedItems.isEmpty) {
              return const EmptyStateCard(message: 'لا يوجد سجل طلبات بعد');
            }
            return ListView.separated(
              itemCount: typedItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext context, int index) {
                final order = typedItems[index];
                return InkWell(
                  onTap: () => context.push('/account/orders/${order.orderNumber}'),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(order.orderNumber, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.sm),
                        OrderStatusChip(label: order.statusLabel, statusCode: order.statusCode),
                        const SizedBox(height: AppSpacing.sm),
                        Text(order.grandTotal.formatted),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ErrorStateCard(
            message: 'تعذر تحميل الطلبات',
            onRetry: () => ref.invalidate(ordersProvider),
          ),
        ),
      ),
    );
  }
}
