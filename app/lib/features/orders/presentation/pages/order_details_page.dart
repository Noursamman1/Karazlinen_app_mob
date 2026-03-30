import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/account/presentation/widgets/account_status_card.dart';
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
    final ProtectedAsyncState<OrderDetailView> detailState = ref.watch(orderDetailStateProvider(orderNumber));
    return Scaffold(
      appBar: AppBar(title: Text('الطلب $orderNumber')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: switch (detailState.status) {
            ProtectedAsyncStatus.requiresAuth => AccountStatusCard(
                title: 'الوصول إلى تفاصيل الطلب يتطلب تسجيل الدخول',
                message: detailState.message ?? 'يرجى تسجيل الدخول للوصول إلى تفاصيل الطلب.',
                actionLabel: 'فتح شاشة الدخول',
                onAction: () => context.go('/auth-required'),
              ),
            ProtectedAsyncStatus.loading => const SectionCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ProtectedAsyncStatus.error => ErrorStateCard(
                message: detailState.message ?? 'تعذر تحميل تفاصيل الطلب',
                onRetry: () => ref.invalidate(orderDetailProvider(orderNumber)),
              ),
            ProtectedAsyncStatus.empty => AccountStatusCard(
                title: 'لا توجد تفاصيل متاحة لهذا الطلب',
                message: detailState.message ?? 'لم يتم العثور على تفاصيل إضافية لهذا الطلب.',
                icon: Icons.inventory_outlined,
              ),
            ProtectedAsyncStatus.ready => _OrderDetailsReadyView(order: detailState.data!),
          },
        ),
      ),
    );
  }
}

class _OrderDetailsReadyView extends StatelessWidget {
  const _OrderDetailsReadyView({
    required this.order,
  });

  final OrderDetailView order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        OrderTimelineSection(order: order),
        const SizedBox(height: AppSpacing.lg),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('ملخص الطلب', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Text(
                'الإجمالي: ${order.grandTotal.formatted}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'عدد المنتجات: ${order.items.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('المنتجات', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              for (final OrderItemView item in order.items) ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'SKU: ${item.sku}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
                          ),
                        ],
                      ),
                    ),
                    Text('x${item.quantity}'),
                    const SizedBox(width: AppSpacing.sm),
                    Text(item.total.formatted),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
        if (order.shippingAddress != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          _OrderAddressCard(
            title: 'عنوان الشحن',
            address: order.shippingAddress!,
          ),
        ],
        if (order.billingAddress != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          _OrderAddressCard(
            title: 'عنوان الفوترة',
            address: order.billingAddress!,
          ),
        ],
      ],
    );
  }
}

class _OrderAddressCard extends StatelessWidget {
  const _OrderAddressCard({
    required this.title,
    required this.address,
  });

  final String title;
  final AddressView address;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text('${address.firstName} ${address.lastName}'),
          const SizedBox(height: AppSpacing.xs),
          Text(address.streetLines.join('، ')),
          Text('${address.city} ${address.region ?? ''}'),
          Text(address.postcode),
          const SizedBox(height: AppSpacing.xs),
          Text(address.phone),
        ],
      ),
    );
  }
}
