import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/account/presentation/widgets/account_status_card.dart';
import 'package:karaz_linen_app/features/address_book/application/address_book_controller.dart';
import 'package:karaz_linen_app/features/cart/application/cart_controller.dart';
import 'package:karaz_linen_app/features/checkout/application/checkout_controller.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  int _currentStep = 0;
  bool _sameAsShipping = true;
  String? _shippingAddressId;
  String? _billingAddressId;
  bool _termsAccepted = false;
  final TextEditingController _customerNoteController = TextEditingController();

  @override
  void dispose() {
    _customerNoteController.dispose();
    ref.read(placeOrderControllerProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProtectedAsyncState<CartView> cartState = ref.watch(cartStateProvider);
    final PlaceOrderState placeOrderState = ref.watch(placeOrderControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Checkout Foundation',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'أكملي خطوات العنوان والشحن والدفع، ثم راجعي الطلب قبل تفعيل place-order في Slice 4.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (placeOrderState.isSuccess && placeOrderState.result != null)
              _PlaceOrderSuccessCard(result: placeOrderState.result!)
            else
              switch (cartState.status) {
                ProtectedAsyncStatus.requiresAuth => AccountStatusCard(
                    title: 'الوصول إلى checkout يتطلب تسجيل الدخول',
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
                    message: cartState.message ?? 'تعذر تحميل بيانات checkout',
                    onRetry: () => ref.invalidate(cartProvider),
                  ),
                ProtectedAsyncStatus.empty => AccountStatusCard(
                    title: 'السلة فارغة',
                    message: 'أضيفي منتجات إلى السلة قبل البدء في checkout.',
                    icon: Icons.shopping_bag_outlined,
                    actionLabel: 'العودة إلى السلة',
                    onAction: () => context.go('/cart'),
                  ),
                ProtectedAsyncStatus.ready => _CheckoutStepper(
                    cart: cartState.data!,
                    currentStep: _currentStep,
                    sameAsShipping: _sameAsShipping,
                    shippingAddressId: _shippingAddressId,
                    billingAddressId: _billingAddressId,
                    onStepChanged: (int next) {
                      setState(() {
                        _currentStep = next;
                      });
                    },
                    onSameAsShippingChanged: (bool value) {
                      setState(() {
                        _sameAsShipping = value;
                        if (value) {
                          _billingAddressId = _shippingAddressId;
                        }
                      });
                    },
                    onShippingAddressChanged: (String? value) {
                      setState(() {
                        _shippingAddressId = value;
                        if (_sameAsShipping) {
                          _billingAddressId = value;
                        }
                      });
                    },
                    onBillingAddressChanged: (String? value) {
                      setState(() {
                        _billingAddressId = value;
                      });
                    },
                    termsAccepted: _termsAccepted,
                    customerNoteController: _customerNoteController,
                    onTermsAcceptedChanged: (bool value) {
                      setState(() {
                        _termsAccepted = value;
                      });
                    },
                  ),
              },
          ],
        ),
      ),
    );
  }
}

class _CheckoutStepper extends ConsumerWidget {
  const _CheckoutStepper({
    required this.cart,
    required this.currentStep,
    required this.sameAsShipping,
    required this.shippingAddressId,
    required this.billingAddressId,
    required this.onStepChanged,
    required this.onSameAsShippingChanged,
    required this.onShippingAddressChanged,
    required this.onBillingAddressChanged,
    required this.termsAccepted,
    required this.customerNoteController,
    required this.onTermsAcceptedChanged,
  });

  final CartView cart;
  final int currentStep;
  final bool sameAsShipping;
  final String? shippingAddressId;
  final String? billingAddressId;
  final ValueChanged<int> onStepChanged;
  final ValueChanged<bool> onSameAsShippingChanged;
  final ValueChanged<String?> onShippingAddressChanged;
  final ValueChanged<String?> onBillingAddressChanged;
  final bool termsAccepted;
  final TextEditingController customerNoteController;
  final ValueChanged<bool> onTermsAcceptedChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProtectedAsyncState<List<AddressView>> addressesState = ref.watch(addressBookStateProvider);
    final ProtectedAsyncState<List<ShippingMethodView>> shippingMethodsState = ref.watch(checkoutShippingMethodsStateProvider);
    final ProtectedAsyncState<List<PaymentMethodView>> paymentMethodsState = ref.watch(checkoutPaymentMethodsStateProvider);
    final PlaceOrderState placeOrderState = ref.watch(placeOrderControllerProvider);

    final List<AddressView> addresses = addressesState.status == ProtectedAsyncStatus.ready ? addressesState.data! : <AddressView>[];
    final String? effectiveShippingAddressId = shippingAddressId ?? cart.shippingAddress?.id;
    final String? effectiveBillingAddressId = billingAddressId ?? cart.billingAddress?.id;
    final bool effectiveSameAsShipping = sameAsShipping || (cart.billingAddress?.id == cart.shippingAddress?.id && cart.billingAddress != null);
    final int safeStep = currentStep < 0
        ? 0
        : currentStep > 3
            ? 3
            : currentStep;

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.lg),
      child: Stepper(
        currentStep: safeStep,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return const SizedBox.shrink();
        },
        onStepTapped: onStepChanged,
        onStepContinue: () => onStepChanged(safeStep >= 3 ? 3 : safeStep + 1),
        onStepCancel: () => onStepChanged(safeStep <= 0 ? 0 : safeStep - 1),
        steps: <Step>[
          Step(
            title: const Text('العنوان'),
            isActive: currentStep >= 0,
            state: _stepState(
              isComplete: cart.shippingAddress != null && cart.billingAddress != null,
              isEditing: currentStep == 0,
            ),
            content: _AddressStepContent(
              addressesState: addressesState,
              shippingAddressId: effectiveShippingAddressId,
              billingAddressId: effectiveBillingAddressId,
              sameAsShipping: effectiveSameAsShipping,
              onSameAsShippingChanged: onSameAsShippingChanged,
              onShippingAddressChanged: onShippingAddressChanged,
              onBillingAddressChanged: onBillingAddressChanged,
              onApply: () async {
                final AddressView? shipping = _findAddress(addresses, effectiveShippingAddressId);
                final AddressView? billing = _findAddress(addresses, effectiveBillingAddressId);
                if (shipping == null) {
                  _showSnack(context, 'اختاري عنوان الشحن أولًا.');
                  return;
                }
                if (!effectiveSameAsShipping && billing == null) {
                  _showSnack(context, 'اختاري عنوان الفوترة أو فعّلي نفس عنوان الشحن.');
                  return;
                }

                final CheckoutActionResult result = await ref.read(checkoutActionsProvider).assignAddresses(
                      shippingAddress: shipping,
                      sameAsShipping: effectiveSameAsShipping,
                      billingAddress: effectiveSameAsShipping ? null : billing,
                    );
                await _handleActionResult(context, result);
                if (result.isSuccess) {
                  onStepChanged(1);
                }
              },
              onManageAddresses: () => context.push('/account/addresses'),
              onRetry: () => ref.invalidate(addressesProvider),
            ),
          ),
          Step(
            title: const Text('الشحن'),
            isActive: currentStep >= 1,
            state: _stepState(
              isComplete: cart.selectedShippingMethod != null,
              isEditing: currentStep == 1,
            ),
            content: _ShippingStepContent(
              cart: cart,
              methodsState: shippingMethodsState,
              onRetry: () => ref.invalidate(checkoutShippingMethodsProvider),
              onSelect: (ShippingMethodView method) async {
                final CheckoutActionResult result = await ref.read(checkoutActionsProvider).selectShippingMethod(
                      carrierCode: method.carrierCode,
                      methodCode: method.methodCode,
                    );
                await _handleActionResult(context, result);
                if (result.isSuccess) {
                  onStepChanged(2);
                }
              },
            ),
          ),
          Step(
            title: const Text('الدفع'),
            isActive: currentStep >= 2,
            state: _stepState(
              isComplete: cart.selectedPaymentMethod != null,
              isEditing: currentStep == 2,
            ),
            content: _PaymentStepContent(
              cart: cart,
              methodsState: paymentMethodsState,
              onRetry: () => ref.invalidate(checkoutPaymentMethodsProvider),
              onSelect: (PaymentMethodView method) async {
                final CheckoutActionResult result = await ref.read(checkoutActionsProvider).selectPaymentMethod(method.code);
                await _handleActionResult(context, result);
                if (result.isSuccess) {
                  onStepChanged(3);
                }
              },
            ),
          ),
          Step(
            title: const Text('المراجعة'),
            isActive: currentStep >= 3,
            state: _stepState(
              isComplete: placeOrderState.isSuccess,
              isEditing: currentStep == 3,
            ),
            content: _ReviewStepContent(
              cart: cart,
              placeOrderState: placeOrderState,
              termsAccepted: termsAccepted,
              customerNoteController: customerNoteController,
              onTermsAcceptedChanged: onTermsAcceptedChanged,
              onPlaceOrder: () => ref.read(placeOrderControllerProvider.notifier).submit(
                    termsAccepted: termsAccepted,
                    customerNote: customerNoteController.text.trim().isEmpty ? null : customerNoteController.text.trim(),
                  ),
              onRetry: () => ref.read(placeOrderControllerProvider.notifier).submit(
                    termsAccepted: termsAccepted,
                    customerNote: customerNoteController.text.trim().isEmpty ? null : customerNoteController.text.trim(),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressStepContent extends StatelessWidget {
  const _AddressStepContent({
    required this.addressesState,
    required this.shippingAddressId,
    required this.billingAddressId,
    required this.sameAsShipping,
    required this.onSameAsShippingChanged,
    required this.onShippingAddressChanged,
    required this.onBillingAddressChanged,
    required this.onApply,
    required this.onManageAddresses,
    required this.onRetry,
  });

  final ProtectedAsyncState<List<AddressView>> addressesState;
  final String? shippingAddressId;
  final String? billingAddressId;
  final bool sameAsShipping;
  final ValueChanged<bool> onSameAsShippingChanged;
  final ValueChanged<String?> onShippingAddressChanged;
  final ValueChanged<String?> onBillingAddressChanged;
  final Future<void> Function() onApply;
  final VoidCallback onManageAddresses;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (addressesState.status) {
      ProtectedAsyncStatus.requiresAuth => AccountStatusCard(
          title: 'يتطلب تسجيل الدخول',
          message: addressesState.message ?? 'لا يمكن تحميل العناوين بدون جلسة نشطة.',
          icon: Icons.lock_outline,
        ),
      ProtectedAsyncStatus.loading => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
      ProtectedAsyncStatus.error => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ErrorStateCard(
              message: addressesState.message ?? 'تعذر تحميل العناوين',
              onRetry: onRetry,
            ),
          ],
        ),
      ProtectedAsyncStatus.empty => AccountStatusCard(
          title: 'لا توجد عناوين محفوظة',
          message: 'أضيفي عنوانًا واحدًا على الأقل للمتابعة في checkout.',
          icon: Icons.location_off_outlined,
          actionLabel: 'إدارة العناوين',
          onAction: onManageAddresses,
        ),
      ProtectedAsyncStatus.ready => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: shippingAddressId,
              decoration: const InputDecoration(
                labelText: 'عنوان الشحن',
                border: OutlineInputBorder(),
              ),
              items: addressesState.data!
                  .map(
                    (AddressView address) => DropdownMenuItem<String>(
                      value: address.id,
                      child: Text(_addressLabel(address)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: onShippingAddressChanged,
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              value: sameAsShipping,
              title: const Text('استخدام نفس العنوان للفوترة'),
              onChanged: onSameAsShippingChanged,
            ),
            if (!sameAsShipping) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: billingAddressId,
                decoration: const InputDecoration(
                  labelText: 'عنوان الفوترة',
                  border: OutlineInputBorder(),
                ),
                items: addressesState.data!
                    .map(
                      (AddressView address) => DropdownMenuItem<String>(
                        value: address.id,
                        child: Text(_addressLabel(address)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: onBillingAddressChanged,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                FilledButton(
                  onPressed: onApply,
                  child: const Text('حفظ العناوين'),
                ),
                OutlinedButton(
                  onPressed: onManageAddresses,
                  child: const Text('إدارة العناوين'),
                ),
              ],
            ),
          ],
        ),
    };
  }
}

class _ShippingStepContent extends StatelessWidget {
  const _ShippingStepContent({
    required this.cart,
    required this.methodsState,
    required this.onRetry,
    required this.onSelect,
  });

  final CartView cart;
  final ProtectedAsyncState<List<ShippingMethodView>> methodsState;
  final VoidCallback onRetry;
  final ValueChanged<ShippingMethodView> onSelect;

  @override
  Widget build(BuildContext context) {
    if (cart.shippingAddress == null) {
      return const AccountStatusCard(
        title: 'أكملي خطوة العنوان أولًا',
        message: 'لا يمكن تحديد طريقة الشحن قبل حفظ عنوان الشحن.',
        icon: Icons.local_shipping_outlined,
      );
    }

    return switch (methodsState.status) {
      ProtectedAsyncStatus.requiresAuth => AccountStatusCard(
          title: 'يتطلب تسجيل الدخول',
          message: methodsState.message ?? 'لا يمكن تحميل طرق الشحن بدون جلسة نشطة.',
          icon: Icons.lock_outline,
        ),
      ProtectedAsyncStatus.loading => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
      ProtectedAsyncStatus.error => ErrorStateCard(
          message: methodsState.message ?? 'تعذر تحميل طرق الشحن',
          onRetry: onRetry,
        ),
      ProtectedAsyncStatus.empty => AccountStatusCard(
          title: 'لا توجد طرق شحن متاحة',
          message: methodsState.message ?? 'تحققي من العنوان أو أعيدي المحاولة.',
          icon: Icons.local_shipping_outlined,
        ),
      ProtectedAsyncStatus.ready => Column(
          children: methodsState.data!
              .map(
                (ShippingMethodView method) => RadioListTile<String>(
                  value: method.key,
                  groupValue: cart.selectedShippingMethod?.key,
                  title: Text(method.label),
                  subtitle: Text(method.detail ?? method.amount.formatted),
                  secondary: Text(method.amount.formatted),
                  onChanged: (_) => onSelect(method),
                ),
              )
              .toList(growable: false),
        ),
    };
  }
}

class _PaymentStepContent extends StatelessWidget {
  const _PaymentStepContent({
    required this.cart,
    required this.methodsState,
    required this.onRetry,
    required this.onSelect,
  });

  final CartView cart;
  final ProtectedAsyncState<List<PaymentMethodView>> methodsState;
  final VoidCallback onRetry;
  final ValueChanged<PaymentMethodView> onSelect;

  @override
  Widget build(BuildContext context) {
    if (cart.selectedShippingMethod == null) {
      return const AccountStatusCard(
        title: 'أكملي خطوة الشحن أولًا',
        message: 'لا يمكن تحديد طريقة الدفع قبل اختيار طريقة الشحن.',
        icon: Icons.payments_outlined,
      );
    }

    return switch (methodsState.status) {
      ProtectedAsyncStatus.requiresAuth => AccountStatusCard(
          title: 'يتطلب تسجيل الدخول',
          message: methodsState.message ?? 'لا يمكن تحميل طرق الدفع بدون جلسة نشطة.',
          icon: Icons.lock_outline,
        ),
      ProtectedAsyncStatus.loading => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
      ProtectedAsyncStatus.error => ErrorStateCard(
          message: methodsState.message ?? 'تعذر تحميل طرق الدفع',
          onRetry: onRetry,
        ),
      ProtectedAsyncStatus.empty => AccountStatusCard(
          title: 'لا توجد طرق دفع متاحة',
          message: methodsState.message ?? 'تحققي من بيانات الشحن أو أعيدي المحاولة.',
          icon: Icons.payments_outlined,
        ),
      ProtectedAsyncStatus.ready => Column(
          children: methodsState.data!
              .map(
                (PaymentMethodView method) => RadioListTile<String>(
                  value: method.code,
                  groupValue: cart.selectedPaymentMethod?.code,
                  title: Text(method.label),
                  subtitle: method.detail == null ? null : Text(method.detail!),
                  onChanged: (_) => onSelect(method),
                ),
              )
              .toList(growable: false),
        ),
    };
  }
}

class _ReviewStepContent extends StatelessWidget {
  const _ReviewStepContent({
    required this.cart,
    required this.placeOrderState,
    required this.termsAccepted,
    required this.customerNoteController,
    required this.onTermsAcceptedChanged,
    required this.onPlaceOrder,
    required this.onRetry,
  });

  final CartView cart;
  final PlaceOrderState placeOrderState;
  final bool termsAccepted;
  final TextEditingController customerNoteController;
  final ValueChanged<bool> onTermsAcceptedChanged;
  final Future<void> Function() onPlaceOrder;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (placeOrderState.isSuccess && placeOrderState.result != null) {
      return _PlaceOrderSuccessCard(result: placeOrderState.result!);
    }

    final bool canSubmit = cart.checkout.ready && termsAccepted && !placeOrderState.isSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ReviewCard(
          title: 'العناصر',
          child: Column(
            children: cart.items
                .map(
                  (CartItemView item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text('${item.name} × ${item.quantity}')),
                        Text(item.lineTotal.formatted),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ReviewCard(
          title: 'الملخص',
          child: Column(
            children: <Widget>[
              _ReviewRow(label: 'الإجمالي الفرعي', value: cart.totals.subtotal.formatted),
              if (cart.totals.shipping != null) _ReviewRow(label: 'الشحن', value: cart.totals.shipping!.formatted),
              if (cart.totals.tax != null) _ReviewRow(label: 'الضريبة', value: cart.totals.tax!.formatted),
              _ReviewRow(label: 'الإجمالي النهائي', value: cart.totals.grandTotal.formatted, emphasize: true),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ReviewCard(
          title: 'حالة الجاهزية',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                cart.checkout.ready ? 'جاهز مبدئيًا لإرسال الطلب.' : 'لا يزال هناك عناصر مطلوبة قبل place-order.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (cart.checkout.blockers.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                for (final String blocker in cart.checkout.blockers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text('• ${_checkoutBlockerLabel(blocker)}'),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ReviewCard(
          title: 'شروط الطلب',
          child: Column(
            children: <Widget>[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: termsAccepted,
                onChanged: (bool? value) => onTermsAcceptedChanged(value ?? false),
                title: const Text('أوافق على الشروط والأحكام'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: customerNoteController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ملاحظة الطلب (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        if (placeOrderState.status == PlaceOrderStatus.failure && placeOrderState.errorMessage != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          ErrorStateCard(
            message: placeOrderState.errorMessage!,
            onRetry: () {
              onRetry();
            },
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: canSubmit
              ? () {
                  onPlaceOrder();
                }
              : null,
          child: placeOrderState.isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تأكيد الطلب'),
        ),
      ],
    );
  }
}

class _PlaceOrderSuccessCard extends StatelessWidget {
  const _PlaceOrderSuccessCard({
    required this.result,
  });

  final PlaceOrderResultView result;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('تم إرسال الطلب بنجاح', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text('رقم الطلب: ${result.orderNumber}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('الحالة: ${result.status}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              FilledButton(
                onPressed: () => context.go('/account/orders'),
                child: const Text('عرض الطلبات'),
              ),
              OutlinedButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('متابعة التسوق'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

StepState _stepState({
  required bool isComplete,
  required bool isEditing,
}) {
  if (isComplete) {
    return StepState.complete;
  }
  if (isEditing) {
    return StepState.editing;
  }
  return StepState.indexed;
}

AddressView? _findAddress(List<AddressView> addresses, String? id) {
  if (id == null) {
    return null;
  }

  for (final AddressView address in addresses) {
    if (address.id == id) {
      return address;
    }
  }
  return null;
}

String _addressLabel(AddressView address) {
  return '${address.city} • ${address.streetLines.join(' - ')}';
}

String _checkoutBlockerLabel(String blockerCode) {
  switch (blockerCode) {
    case 'cart_empty':
      return 'السلة فارغة';
    case 'shipping_address_missing':
      return 'عنوان الشحن غير مكتمل';
    case 'billing_address_missing':
      return 'عنوان الفوترة غير مكتمل';
    case 'shipping_method_missing':
      return 'طريقة الشحن غير محددة';
    case 'payment_method_missing':
      return 'طريقة الدفع غير محددة';
    default:
      return blockerCode;
  }
}

Future<void> _handleActionResult(
  BuildContext context,
  CheckoutActionResult result,
) async {
  if (!context.mounted) {
    return;
  }

  if (result.needsAuth) {
    context.go('/auth-required');
    return;
  }

  _showSnack(context, result.message);
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
