import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/features/account/application/account_controller.dart';
import 'package:karaz_linen_app/features/account/application/protected_state_mapper.dart';
import 'package:karaz_linen_app/features/account/domain/account_access_state.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/cart/application/cart_controller.dart';
import 'package:karaz_linen_app/features/checkout/application/checkout_use_cases.dart';

class CheckoutActionResult {
  const CheckoutActionResult._({
    required this.status,
    required this.message,
  });

  const CheckoutActionResult.success(String message)
      : this._(
          status: CheckoutActionStatus.success,
          message: message,
        );

  const CheckoutActionResult.requiresAuth(String message)
      : this._(
          status: CheckoutActionStatus.requiresAuth,
          message: message,
        );

  const CheckoutActionResult.failure(String message)
      : this._(
          status: CheckoutActionStatus.failure,
          message: message,
        );

  final CheckoutActionStatus status;
  final String message;

  bool get isSuccess => status == CheckoutActionStatus.success;
  bool get needsAuth => status == CheckoutActionStatus.requiresAuth;
}

enum CheckoutActionStatus {
  success,
  requiresAuth,
  failure,
}

enum PlaceOrderStatus {
  idle,
  submitting,
  success,
  failure,
}

class PlaceOrderState {
  const PlaceOrderState({
    required this.status,
    this.result,
    this.errorCode,
    this.errorMessage,
    this.idempotencyKey,
  });

  const PlaceOrderState.idle() : this(status: PlaceOrderStatus.idle);

  final PlaceOrderStatus status;
  final PlaceOrderResultView? result;
  final String? errorCode;
  final String? errorMessage;
  final String? idempotencyKey;

  bool get isSubmitting => status == PlaceOrderStatus.submitting;
  bool get isSuccess => status == PlaceOrderStatus.success;
}

final checkoutShippingMethodsProvider = FutureProvider<List<ShippingMethodView>>((Ref ref) {
  return ref.watch(loadCheckoutShippingMethodsUseCaseProvider).call();
});

final Provider<ProtectedAsyncState<List<ShippingMethodView>>> checkoutShippingMethodsStateProvider =
    Provider<ProtectedAsyncState<List<ShippingMethodView>>>((Ref ref) {
  final AccountAccessState access = ref.watch(accountAccessStateProvider);
  if (!access.canAccessProtectedData) {
    return ProtectedAsyncState<List<ShippingMethodView>>.requiresAuth(access.guardMessage);
  }

  return mapProtectedAsyncState<List<ShippingMethodView>>(
    access: access,
    asyncValue: ref.watch(checkoutShippingMethodsProvider),
    isEmpty: (List<ShippingMethodView> value) => value.isEmpty,
    emptyMessage: 'لا توجد طرق شحن متاحة حاليًا.',
    errorMessage: 'تعذر تحميل طرق الشحن',
  );
});

final checkoutPaymentMethodsProvider = FutureProvider<List<PaymentMethodView>>((Ref ref) {
  return ref.watch(loadCheckoutPaymentMethodsUseCaseProvider).call();
});

final Provider<ProtectedAsyncState<List<PaymentMethodView>>> checkoutPaymentMethodsStateProvider =
    Provider<ProtectedAsyncState<List<PaymentMethodView>>>((Ref ref) {
  final AccountAccessState access = ref.watch(accountAccessStateProvider);
  if (!access.canAccessProtectedData) {
    return ProtectedAsyncState<List<PaymentMethodView>>.requiresAuth(access.guardMessage);
  }

  return mapProtectedAsyncState<List<PaymentMethodView>>(
    access: access,
    asyncValue: ref.watch(checkoutPaymentMethodsProvider),
    isEmpty: (List<PaymentMethodView> value) => value.isEmpty,
    emptyMessage: 'لا توجد طرق دفع متاحة حاليًا.',
    errorMessage: 'تعذر تحميل طرق الدفع',
  );
});

final Provider<CheckoutActions> checkoutActionsProvider = Provider<CheckoutActions>((Ref ref) {
  return CheckoutActions(ref);
});

final StateNotifierProvider<PlaceOrderController, PlaceOrderState> placeOrderControllerProvider =
    StateNotifierProvider<PlaceOrderController, PlaceOrderState>((StateNotifierProviderRef<PlaceOrderController, PlaceOrderState> ref) {
  return PlaceOrderController(ref);
});

class CheckoutActions {
  CheckoutActions(this._ref);

  final Ref _ref;

  Future<CheckoutActionResult> assignAddresses({
    required AddressView shippingAddress,
    required bool sameAsShipping,
    AddressView? billingAddress,
  }) async {
    final AccountAccessState access = _ref.read(accountAccessStateProvider);
    if (!access.canAccessProtectedData) {
      return CheckoutActionResult.requiresAuth(access.guardMessage);
    }

    try {
      await _ref.read(assignCheckoutAddressesUseCaseProvider).call(
            CartAddressAssignmentInput(
              shippingAddress: shippingAddress,
              sameAsShipping: sameAsShipping,
              billingAddress: billingAddress,
            ),
          );
      _ref.invalidate(cartProvider);
      _ref.invalidate(checkoutShippingMethodsProvider);
      _ref.invalidate(checkoutPaymentMethodsProvider);
      return const CheckoutActionResult.success('تم تحديث عناوين checkout.');
    } catch (_) {
      return const CheckoutActionResult.failure('تعذر حفظ العناوين.');
    }
  }

  Future<CheckoutActionResult> selectShippingMethod({
    required String carrierCode,
    required String methodCode,
  }) async {
    final AccountAccessState access = _ref.read(accountAccessStateProvider);
    if (!access.canAccessProtectedData) {
      return CheckoutActionResult.requiresAuth(access.guardMessage);
    }

    try {
      await _ref.read(selectCheckoutShippingMethodUseCaseProvider).call(
            carrierCode: carrierCode,
            methodCode: methodCode,
          );
      _ref.invalidate(cartProvider);
      _ref.invalidate(checkoutShippingMethodsProvider);
      _ref.invalidate(checkoutPaymentMethodsProvider);
      return const CheckoutActionResult.success('تم اختيار طريقة الشحن.');
    } catch (_) {
      return const CheckoutActionResult.failure('تعذر حفظ طريقة الشحن.');
    }
  }

  Future<CheckoutActionResult> selectPaymentMethod(String code) async {
    final AccountAccessState access = _ref.read(accountAccessStateProvider);
    if (!access.canAccessProtectedData) {
      return CheckoutActionResult.requiresAuth(access.guardMessage);
    }

    try {
      await _ref.read(selectCheckoutPaymentMethodUseCaseProvider).call(code);
      _ref.invalidate(cartProvider);
      _ref.invalidate(checkoutPaymentMethodsProvider);
      return const CheckoutActionResult.success('تم اختيار طريقة الدفع.');
    } catch (_) {
      return const CheckoutActionResult.failure('تعذر حفظ طريقة الدفع.');
    }
  }
}

class PlaceOrderController extends StateNotifier<PlaceOrderState> {
  PlaceOrderController(this._ref) : super(const PlaceOrderState.idle());

  final Ref _ref;
  String? _inflightKey;

  Future<void> submit({
    required bool termsAccepted,
    String? customerNote,
  }) async {
    if (state.isSubmitting) {
      return;
    }

    final AccountAccessState access = _ref.read(accountAccessStateProvider);
    if (!access.canAccessProtectedData) {
      state = PlaceOrderState(
        status: PlaceOrderStatus.failure,
        errorCode: 'requires_auth',
        errorMessage: access.guardMessage,
      );
      return;
    }

    final String key = _inflightKey ?? _generateIdempotencyKey();
    _inflightKey = key;
    state = PlaceOrderState(
      status: PlaceOrderStatus.submitting,
      idempotencyKey: key,
    );

    try {
      final PlaceOrderResultView result = await _ref.read(placeOrderUseCaseProvider).call(
            PlaceOrderInput(
              idempotencyKey: key,
              termsAccepted: termsAccepted,
              customerNote: customerNote,
            ),
          );

      state = PlaceOrderState(
        status: PlaceOrderStatus.success,
        result: result,
        idempotencyKey: key,
      );

      _ref.invalidate(cartProvider);
      _ref.invalidate(checkoutShippingMethodsProvider);
      _ref.invalidate(checkoutPaymentMethodsProvider);
      _inflightKey = null;
    } catch (error) {
      final (String code, String message) normalized = _normalizePlaceOrderError(error);
      state = PlaceOrderState(
        status: PlaceOrderStatus.failure,
        errorCode: code,
        errorMessage: message,
        idempotencyKey: key,
      );
    }
  }

  void reset() {
    _inflightKey = null;
    state = const PlaceOrderState.idle();
  }

  String _generateIdempotencyKey() {
    final int now = DateTime.now().microsecondsSinceEpoch;
    return 'checkout-$now';
  }

  (String, String) _normalizePlaceOrderError(Object error) {
    final String message = error.toString().toLowerCase();
    if (message.contains('checkout_not_ready')) {
      return ('checkout_not_ready', 'لا يمكن تأكيد الطلب قبل اكتمال جميع خطوات checkout.');
    }
    if (message.contains('terms_not_accepted')) {
      return ('terms_not_accepted', 'يجب الموافقة على الشروط قبل تأكيد الطلب.');
    }
    if (message.contains('idempotency_key_required')) {
      return ('idempotency_key_required', 'تعذر إرسال الطلب: idempotency key مفقود.');
    }
    if (message.contains('upstream')) {
      return ('upstream_unavailable', 'خدمة الطلبات غير متاحة حاليًا، حاولي مرة أخرى لاحقًا.');
    }
    return ('unknown_error', 'تعذر إتمام الطلب في الوقت الحالي.');
  }
}
