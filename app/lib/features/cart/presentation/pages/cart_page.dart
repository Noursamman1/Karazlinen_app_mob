import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/account/presentation/widgets/account_status_card.dart';
import 'package:karaz_linen_app/features/cart/application/cart_controller.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProtectedAsyncState<CartView> cartState = ref.watch(cartStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('السلة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'سلة المشتريات',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'راجعي العناصر وحدّثي الكميات قبل الانتقال إلى checkout.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            switch (cartState.status) {
              ProtectedAsyncStatus.requiresAuth => AccountStatusCard(
                  title: 'الوصول إلى السلة يتطلب تسجيل الدخول',
                  message: cartState.message ?? 'يرجى تسجيل الدخول للمتابعة.',
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
                  message: cartState.message ?? 'تعذر تحميل السلة',
                  onRetry: () => ref.invalidate(cartProvider),
                ),
              ProtectedAsyncStatus.empty => AccountStatusCard(
                  title: 'السلة فارغة',
                  message: cartState.message ?? 'ابدئي بإضافة منتجات من صفحة المنتج.',
                  icon: Icons.shopping_bag_outlined,
                  actionLabel: 'تصفح المنتجات',
                  onAction: () => context.go('/catalog'),
                ),
              ProtectedAsyncStatus.ready => _CartReadyView(cart: cartState.data!),
            },
          ],
        ),
      ),
    );
  }
}

class _CartReadyView extends ConsumerWidget {
  const _CartReadyView({
    required this.cart,
  });

  final CartView cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: <Widget>[
        SectionCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: _CartMetaItem(
                  label: 'عدد القطع',
                  value: cart.itemCount.toString(),
                ),
              ),
              Expanded(
                child: _CartMetaItem(
                  label: 'معرّف السلة',
                  value: cart.id,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final CartItemView item in cart.items) ...<Widget>[
          _CartItemCard(
            item: item,
            onIncrease: () => _runCartAction(
              context,
              ref,
              () => ref.read(cartActionsProvider).updateItemQuantity(item.itemId, item.quantity + 1),
            ),
            onDecrease: () => _runCartAction(
              context,
              ref,
              () => item.quantity > 1
                  ? ref.read(cartActionsProvider).updateItemQuantity(item.itemId, item.quantity - 1)
                  : ref.read(cartActionsProvider).removeItem(item.itemId),
            ),
            onRemove: () => _runCartAction(
              context,
              ref,
              () => ref.read(cartActionsProvider).removeItem(item.itemId),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _CartTotalsCard(totals: cart.totals),
        const SizedBox(height: AppSpacing.md),
        _CheckoutFoundationCard(
          onOpenCheckout: () => context.push('/checkout'),
        ),
      ],
    );
  }

  Future<void> _runCartAction(
    BuildContext context,
    WidgetRef ref,
    Future<CartActionResult> Function() action,
  ) async {
    final CartActionResult result = await action();
    if (!context.mounted) {
      return;
    }

    if (result.needsAuth) {
      context.go('/auth-required');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItemView item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: item.thumbnail == null
                      ? const DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.mist),
                          child: Icon(Icons.photo_outlined, color: AppColors.accent),
                        )
                      : Image.network(item.thumbnail!.url, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text('SKU: ${item.sku}', style: Theme.of(context).textTheme.bodySmall),
                    if (item.selectedOptions.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: item.selectedOptions
                            .map(
                              (CartSelectedOptionView option) => InputChip(
                                label: Text('${option.label}: ${option.value}'),
                                onPressed: null,
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              _QuantityButton(
                icon: Icons.remove,
                onPressed: onDecrease,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  item.quantity.toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onPressed: onIncrease,
              ),
              const Spacer(),
              Text(item.lineTotal.formatted, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                tooltip: 'حذف العنصر',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _CartTotalsCard extends StatelessWidget {
  const _CartTotalsCard({
    required this.totals,
  });

  final CartTotalsView totals;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('ملخص المبالغ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _TotalsRow(label: 'الإجمالي الفرعي', value: totals.subtotal.formatted),
          if (totals.shipping != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            _TotalsRow(label: 'الشحن', value: totals.shipping!.formatted),
          ],
          if (totals.tax != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            _TotalsRow(label: 'الضريبة', value: totals.tax!.formatted),
          ],
          if (totals.discount != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            _TotalsRow(label: 'الخصم', value: totals.discount!.formatted),
          ],
          const Divider(height: AppSpacing.lg),
          _TotalsRow(
            label: 'الإجمالي النهائي',
            value: totals.grandTotal.formatted,
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = emphasize ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.bodyLarge;
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _CheckoutFoundationCard extends StatelessWidget {
  const _CheckoutFoundationCard({
    required this.onOpenCheckout,
  });

  final VoidCallback onOpenCheckout;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('المتابعة إلى الدفع', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'يمكنك الآن البدء في checkout foundation. تأكيد الطلب النهائي سيُفعّل في Slice 4.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onOpenCheckout,
            child: const Text('بدء checkout'),
          ),
        ],
      ),
    );
  }
}

class _CartMetaItem extends StatelessWidget {
  const _CartMetaItem({
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
