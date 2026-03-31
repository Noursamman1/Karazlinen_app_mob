import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/cart/application/cart_controller.dart';
import 'package:karaz_linen_app/features/product/domain/product_selection.dart';
import 'package:karaz_linen_app/test/test_support/account_test_helpers.dart';
import 'package:karaz_linen_app/test/test_support/fake_cart_repository.dart';

void main() {
  test('cart state requires auth without fetching cart data', () {
    final FakeCartRepository repository = FakeCartRepository();
    final container = createAccountTestContainer(
      cartRepository: repository,
      authenticated: false,
    );
    addTearDown(container.dispose);

    final ProtectedAsyncState<CartView> state = container.read(cartStateProvider);
    expect(state.status, ProtectedAsyncStatus.requiresAuth);
    expect(repository.fetchCount, 0);
  });

  test('cart state becomes ready for authenticated sessions', () async {
    final FakeCartRepository repository = FakeCartRepository();
    final container = createAccountTestContainer(
      cartRepository: repository,
      authenticated: true,
    );
    addTearDown(container.dispose);

    expect(container.read(cartStateProvider).status, ProtectedAsyncStatus.loading);

    await container.read(cartProvider.future);

    final ProtectedAsyncState<CartView> state = container.read(cartStateProvider);
    expect(state.status, ProtectedAsyncStatus.ready);
    expect(state.data?.items, hasLength(1));
    expect(repository.fetchCount, 1);
  });

  test('cart state becomes empty when cart has no items', () async {
    final FakeCartRepository repository = FakeCartRepository(
      cart: FakeCartRepository.emptyCart,
    );
    final container = createAccountTestContainer(
      cartRepository: repository,
      authenticated: true,
    );
    addTearDown(container.dispose);

    await container.read(cartProvider.future);

    final ProtectedAsyncState<CartView> state = container.read(cartStateProvider);
    expect(state.status, ProtectedAsyncStatus.empty);
    expect(state.message, 'لا توجد عناصر في السلة بعد.');
  });

  test('cart state surfaces repository errors', () async {
    final FakeCartRepository repository = FakeCartRepository(
      fetchError: StateError('fetch failed'),
    );
    final container = createAccountTestContainer(
      cartRepository: repository,
      authenticated: true,
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(cartProvider.future),
      throwsA(isA<StateError>()),
    );

    final ProtectedAsyncState<CartView> state = container.read(cartStateProvider);
    expect(state.status, ProtectedAsyncStatus.error);
    expect(state.message, 'تعذر تحميل السلة');
  });

  test('cart actions add/update/remove flow updates cart snapshot', () async {
    final FakeCartRepository repository = FakeCartRepository();
    final container = createAccountTestContainer(
      cartRepository: repository,
      authenticated: true,
    );
    addTearDown(container.dispose);

    final CartActions actions = container.read(cartActionsProvider);
    final ProductSelectionSummary summary = const ProductSelectionSummary(
      selectedOptions: <SelectedProductOption>[
        SelectedProductOption(
          code: 'size',
          label: 'المقاس',
          value: 'queen',
          valueLabel: 'كوين',
        ),
      ],
      missingOptionLabels: <String>[],
      previewMode: ProductVariantPreviewMode.resolvedCombination,
      previewSku: 'KL-200-Q-WHT',
      previewPrice: MoneyView(amount: 249, currencyCode: 'SAR', formatted: '249 ر.س'),
      previewAvailabilityCode: 'in_stock',
      previewAvailabilityLabel: 'متوفر',
      previewImage: ImageView(url: 'https://example.com/pillow.jpg'),
      headline: 'جاهز',
      helperText: 'جاهز للإضافة',
      isPlaceholder: false,
    );

    final CartActionResult addResult = await actions.addFromProductSelection(
      productId: 'sku-200',
      fallbackSku: 'KL-200',
      name: 'وسادة إيلاف',
      quantity: 1,
      selection: summary,
    );
    expect(addResult.isSuccess, isTrue);
    expect(repository.addCount, 1);

    CartView cart = await container.read(cartProvider.future);
    expect(cart.itemCount, 2);

    final CartActionResult updateResult = await actions.updateItemQuantity('item-1', 3);
    expect(updateResult.isSuccess, isTrue);
    expect(repository.updateCount, 1);

    cart = await container.read(cartProvider.future);
    final CartItemView updated = cart.items.firstWhere((CartItemView item) => item.itemId == 'item-1');
    expect(updated.quantity, 3);

    final CartActionResult removeResult = await actions.removeItem('item-1');
    expect(removeResult.isSuccess, isTrue);
    expect(repository.removeCount, 1);
  });

  test('cart add action returns requires-auth without mutating repository', () async {
    final FakeCartRepository repository = FakeCartRepository();
    final container = createAccountTestContainer(
      cartRepository: repository,
      authenticated: false,
    );
    addTearDown(container.dispose);

    final CartActionResult result = await container.read(cartActionsProvider).addFromProductSelection(
          productId: 'sku-200',
          fallbackSku: 'KL-200',
          name: 'وسادة إيلاف',
          quantity: 1,
          selection: const ProductSelectionSummary(
            selectedOptions: <SelectedProductOption>[],
            missingOptionLabels: <String>[],
            previewMode: ProductVariantPreviewMode.baseProduct,
            previewSku: 'KL-200',
            previewPrice: MoneyView(amount: 249, currencyCode: 'SAR', formatted: '249 ر.س'),
            previewAvailabilityCode: 'in_stock',
            previewAvailabilityLabel: 'متوفر',
            previewImage: null,
            headline: 'جاهز',
            helperText: 'جاهز',
            isPlaceholder: false,
          ),
        );

    expect(result.needsAuth, isTrue);
    expect(repository.addCount, 0);
  });
}
