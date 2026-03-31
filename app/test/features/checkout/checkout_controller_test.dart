import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/core/repositories/cart_repository.dart';
import 'package:karaz_linen_app/features/checkout/application/checkout_controller.dart';
import 'package:karaz_linen_app/test/test_support/account_test_helpers.dart';
import 'package:karaz_linen_app/test/test_support/fake_cart_repository.dart';

void main() {
  test('place-order succeeds when checkout is ready and terms are accepted', () async {
    final FakeCartRepository repository = FakeCartRepository(
      cart: FakeCartRepository.readyCheckoutCart,
    );
    final container = createAccountTestContainer(
      authenticated: true,
      cartRepository: repository,
    );
    addTearDown(container.dispose);

    await container.read(placeOrderControllerProvider.notifier).submit(
          termsAccepted: true,
          customerNote: 'الرجاء التواصل قبل التسليم',
        );

    final PlaceOrderState state = container.read(placeOrderControllerProvider);
    expect(state.status, PlaceOrderStatus.success);
    expect(state.result?.status, 'placed');
    expect(repository.placeOrderCount, 1);
  });

  test('place-order fails with requires-auth when no authenticated session exists', () async {
    final FakeCartRepository repository = FakeCartRepository(
      cart: FakeCartRepository.readyCheckoutCart,
    );
    final container = createAccountTestContainer(
      authenticated: false,
      cartRepository: repository,
    );
    addTearDown(container.dispose);

    await container.read(placeOrderControllerProvider.notifier).submit(
          termsAccepted: true,
        );

    final PlaceOrderState state = container.read(placeOrderControllerProvider);
    expect(state.status, PlaceOrderStatus.failure);
    expect(state.errorCode, 'requires_auth');
    expect(repository.placeOrderCount, 0);
  });

  test('place-order fails with normalized error when terms are not accepted', () async {
    final FakeCartRepository repository = FakeCartRepository(
      cart: FakeCartRepository.readyCheckoutCart,
    );
    final container = createAccountTestContainer(
      authenticated: true,
      cartRepository: repository,
    );
    addTearDown(container.dispose);

    await container.read(placeOrderControllerProvider.notifier).submit(
          termsAccepted: false,
        );

    final PlaceOrderState state = container.read(placeOrderControllerProvider);
    expect(state.status, PlaceOrderStatus.failure);
    expect(state.errorCode, 'terms_not_accepted');
  });

  test('double submit guard triggers only one place-order call while submitting', () async {
    final FakeCartRepository repository = FakeCartRepository(
      cart: FakeCartRepository.readyCheckoutCart,
      placeOrderDelay: const Duration(milliseconds: 40),
    );
    final container = createAccountTestContainer(
      authenticated: true,
      cartRepository: repository,
    );
    addTearDown(container.dispose);

    final PlaceOrderController notifier = container.read(placeOrderControllerProvider.notifier);

    final Future<void> first = notifier.submit(termsAccepted: true);
    final Future<void> second = notifier.submit(termsAccepted: true);
    await Future.wait(<Future<void>>[first, second]);

    expect(repository.placeOrderCount, 1);
    expect(container.read(placeOrderControllerProvider).status, PlaceOrderStatus.success);
  });

  test('retry after failure reuses idempotency key inside the same attempt context', () async {
    final _RetryAwareCartRepository repository = _RetryAwareCartRepository();
    final container = createAccountTestContainer(
      authenticated: true,
      cartRepository: repository,
    );
    addTearDown(container.dispose);

    final PlaceOrderController notifier = container.read(placeOrderControllerProvider.notifier);
    await notifier.submit(termsAccepted: true);
    final PlaceOrderState failed = container.read(placeOrderControllerProvider);
    expect(failed.status, PlaceOrderStatus.failure);
    expect(failed.errorCode, 'upstream_unavailable');

    await notifier.submit(termsAccepted: true);
    final PlaceOrderState success = container.read(placeOrderControllerProvider);
    expect(success.status, PlaceOrderStatus.success);

    expect(repository.idempotencyKeys, hasLength(2));
    expect(repository.idempotencyKeys.first, repository.idempotencyKeys.last);
  });

  test('place-order is idempotent for repeated idempotency keys at repository level', () async {
    final FakeCartRepository repository = FakeCartRepository(
      cart: FakeCartRepository.readyCheckoutCart,
    );

    final PlaceOrderResultView first = await repository.placeOrder(
      const PlaceOrderInput(
        idempotencyKey: 'fixed-key-123',
        termsAccepted: true,
      ),
    );
    final PlaceOrderResultView second = await repository.placeOrder(
      const PlaceOrderInput(
        idempotencyKey: 'fixed-key-123',
        termsAccepted: true,
      ),
    );

    expect(first.orderNumber, second.orderNumber);
    expect(first.status, second.status);
  });
}

class _RetryAwareCartRepository implements CartRepository {
  int _attempts = 0;
  final List<String> idempotencyKeys = <String>[];

  @override
  Future<PlaceOrderResultView> placeOrder(PlaceOrderInput input) async {
    idempotencyKeys.add(input.idempotencyKey);
    if (_attempts == 0) {
      _attempts += 1;
      throw StateError('upstream unavailable');
    }
    return const PlaceOrderResultView(
      orderNumber: 'KZ-200001',
      status: 'placed',
    );
  }

  @override
  Future<CartView> addItem(AddCartItemInput input) async => throw UnimplementedError();

  @override
  Future<CartView> assignAddresses(CartAddressAssignmentInput input) async => throw UnimplementedError();

  @override
  Future<CartView> fetchCart() async => throw UnimplementedError();

  @override
  Future<List<PaymentMethodView>> listPaymentMethods() async => const <PaymentMethodView>[];

  @override
  Future<List<ShippingMethodView>> listShippingMethods() async => const <ShippingMethodView>[];

  @override
  Future<CartView> removeItem(String itemId) async => throw UnimplementedError();

  @override
  Future<CartView> selectPaymentMethod(String code) async => throw UnimplementedError();

  @override
  Future<CartView> selectShippingMethod({
    required String carrierCode,
    required String methodCode,
  }) async =>
      throw UnimplementedError();

  @override
  Future<CartView> updateItemQuantity(String itemId, int quantity) async => throw UnimplementedError();
}
