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
import 'package:karaz_linen_app/features/orders/presentation/widgets/order_status_chip.dart';

class OrdersListPage extends ConsumerWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProtectedAsyncState<OrdersListingView> ordersState = ref.watch(ordersStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'سجل الطلبات',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'استعرضي الطلبات السابقة وتتبعي الحالة والتفاصيل من نفس المسار المحمي.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            switch (ordersState.status) {
              ProtectedAsyncStatus.requiresAuth => AccountStatusCard(
                  title: 'الوصول إلى الطلبات يتطلب تسجيل الدخول',
                  message: ordersState.message ?? 'يرجى تسجيل الدخول للوصول إلى الطلبات.',
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
                  message: ordersState.message ?? 'تعذر تحميل الطلبات',
                  onRetry: () => ref.invalidate(ordersProvider),
                ),
              ProtectedAsyncStatus.empty => AccountStatusCard(
                  title: 'لا يوجد سجل طلبات بعد',
                  message: ordersState.message ?? 'ستظهر الطلبات هنا بمجرد بدء الشراء من التطبيق أو المتجر.',
                  icon: Icons.inventory_2_outlined,
                ),
              ProtectedAsyncStatus.ready => _OrdersReadyView(
                  listing: ordersState.data!,
                  onOpenOrder: (String orderNumber) => context.push('/account/orders/$orderNumber'),
                ),
            },
          ],
        ),
      ),
    );
  }
}

class _OrdersReadyView extends StatelessWidget {
  const _OrdersReadyView({
    required this.listing,
    required this.onOpenOrder,
  });

  final OrdersListingView listing;
  final ValueChanged<String> onOpenOrder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SectionCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: _OrdersMetaItem(
                  label: 'إجمالي الطلبات',
                  value: listing.meta.totalItems.toString(),
                ),
              ),
              Expanded(
                child: _OrdersMetaItem(
                  label: 'الصفحة الحالية',
                  value: '${listing.meta.page}/${listing.meta.totalPages}',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listing.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (BuildContext context, int index) {
            final OrderSummaryView order = listing.items[index];
            return InkWell(
              onTap: () => onOpenOrder(order.orderNumber),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(order.orderNumber, style: Theme.of(context).textTheme.titleLarge),
                        ),
                        OrderStatusChip(label: order.statusLabel, statusCode: order.statusCode),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'إجمالي الطلب: ${order.grandTotal.formatted}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'تاريخ الإنشاء: ${_formatOrderDate(order.placedAt)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OrdersMetaItem extends StatelessWidget {
  const _OrdersMetaItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.mutedInk),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

String _formatOrderDate(DateTime value) {
  final DateTime local = value.toLocal();
  return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
}
