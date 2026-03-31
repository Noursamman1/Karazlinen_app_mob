import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/core/repositories/cart_repository.dart';

class FakeCartRepository implements CartRepository {
  FakeCartRepository({
    CartView? cart,
    this.fetchError,
    this.addError,
    this.updateError,
    this.removeError,
    this.assignAddressesError,
    this.listShippingMethodsError,
    this.selectShippingMethodError,
    this.listPaymentMethodsError,
    this.selectPaymentMethodError,
    this.placeOrderError,
    this.placeOrderDelay,
    List<ShippingMethodView>? shippingMethods,
    List<PaymentMethodView>? paymentMethods,
  })  : _cart = cart ?? sampleCart,
        _shippingMethods = List<ShippingMethodView>.from(shippingMethods ?? sampleShippingMethods),
        _paymentMethods = List<PaymentMethodView>.from(paymentMethods ?? samplePaymentMethods);

  CartView _cart;
  List<ShippingMethodView> _shippingMethods;
  List<PaymentMethodView> _paymentMethods;
  final Map<String, PlaceOrderResultView> _placedOrdersByIdempotencyKey = <String, PlaceOrderResultView>{};
  final Object? fetchError;
  final Object? addError;
  final Object? updateError;
  final Object? removeError;
  final Object? assignAddressesError;
  final Object? listShippingMethodsError;
  final Object? selectShippingMethodError;
  final Object? listPaymentMethodsError;
  final Object? selectPaymentMethodError;
  final Object? placeOrderError;
  final Duration? placeOrderDelay;

  int fetchCount = 0;
  int addCount = 0;
  int updateCount = 0;
  int removeCount = 0;
  int assignAddressCount = 0;
  int listShippingMethodsCount = 0;
  int selectShippingMethodCount = 0;
  int listPaymentMethodsCount = 0;
  int selectPaymentMethodCount = 0;
  int placeOrderCount = 0;
  int _orderSequence = 100060;

  static const AddressView sampleShippingAddress = AddressView(
    id: 'addr-1',
    firstName: 'نورة',
    lastName: 'التميمي',
    phone: '+966500000000',
    country: 'SA',
    city: 'Riyadh',
    streetLines: <String>['شارع العليا 22'],
    postcode: '12214',
    isDefaultBilling: true,
    isDefaultShipping: true,
  );

  static const AddressView sampleBillingAddress = AddressView(
    id: 'addr-2',
    firstName: 'نورة',
    lastName: 'التميمي',
    phone: '+966500000000',
    country: 'SA',
    city: 'Riyadh',
    streetLines: <String>['طريق الملك فهد 18'],
    postcode: '12211',
    isDefaultBilling: false,
    isDefaultShipping: false,
  );

  static final List<ShippingMethodView> sampleShippingMethods = <ShippingMethodView>[
    ShippingMethodView(
      carrierCode: 'flat_rate',
      methodCode: 'standard',
      label: 'توصيل قياسي',
      detail: '3-5 أيام عمل',
      amount: const MoneyView(amount: 35, currencyCode: 'SAR', formatted: '35 ر.س'),
      selected: false,
    ),
    ShippingMethodView(
      carrierCode: 'express',
      methodCode: 'next_day',
      label: 'توصيل سريع',
      detail: 'خلال يوم عمل',
      amount: const MoneyView(amount: 55, currencyCode: 'SAR', formatted: '55 ر.س'),
      selected: false,
    ),
  ];

  static const List<PaymentMethodView> samplePaymentMethods = <PaymentMethodView>[
    PaymentMethodView(
      code: 'cashondelivery',
      label: 'الدفع عند الاستلام',
      detail: 'نقدًا عند الاستلام',
      selected: false,
    ),
    PaymentMethodView(
      code: 'banktransfer',
      label: 'تحويل بنكي',
      detail: 'تحويل إلى حساب الشركة',
      selected: false,
    ),
  ];

  static final CartView sampleCart = CartView(
    id: 'cart-1',
    currencyCode: 'SAR',
    itemCount: 1,
    items: <CartItemView>[
      CartItemView(
        itemId: 'item-1',
        productId: 'sku-100',
        sku: 'KL-100-Q-SND',
        name: 'طقم سرير سيرين',
        quantity: 1,
        unitPrice: const MoneyView(amount: 429, currencyCode: 'SAR', formatted: '429 ر.س'),
        lineTotal: const MoneyView(amount: 429, currencyCode: 'SAR', formatted: '429 ر.س'),
        thumbnail: const ImageView(url: 'https://example.com/variant-image.jpg'),
        selectedOptions: const <CartSelectedOptionView>[
          CartSelectedOptionView(code: 'size', label: 'المقاس', value: 'كوين'),
          CartSelectedOptionView(code: 'color', label: 'اللون', value: 'رملي'),
        ],
      ),
    ],
    totals: const CartTotalsView(
      subtotal: MoneyView(amount: 429, currencyCode: 'SAR', formatted: '429 ر.س'),
      shipping: MoneyView(amount: 35, currencyCode: 'SAR', formatted: '35 ر.س'),
      tax: MoneyView(amount: 64.35, currencyCode: 'SAR', formatted: '64.35 ر.س'),
      grandTotal: MoneyView(amount: 528.35, currencyCode: 'SAR', formatted: '528.35 ر.س'),
    ),
    checkout: CheckoutStateView(
      ready: false,
      blockers: <String>[
        'shipping_address_missing',
        'billing_address_missing',
        'shipping_method_missing',
        'payment_method_missing',
      ],
    ),
  );

  static final CartView readyCheckoutCart = CartView(
    id: 'cart-1',
    currencyCode: 'SAR',
    itemCount: 1,
    items: sampleCart.items,
    shippingAddress: sampleShippingAddress,
    billingAddress: sampleShippingAddress,
    selectedShippingMethod: sampleShippingMethods.first.copyWith(selected: true),
    selectedPaymentMethod: samplePaymentMethods.first.copyWith(selected: true),
    totals: const CartTotalsView(
      subtotal: MoneyView(amount: 429, currencyCode: 'SAR', formatted: '429 ر.س'),
      shipping: MoneyView(amount: 35, currencyCode: 'SAR', formatted: '35 ر.س'),
      tax: MoneyView(amount: 69.6, currencyCode: 'SAR', formatted: '69.60 ر.س'),
      grandTotal: MoneyView(amount: 533.6, currencyCode: 'SAR', formatted: '533.60 ر.س'),
    ),
    checkout: const CheckoutStateView(
      ready: true,
      blockers: <String>[],
    ),
  );

  static const CartView emptyCart = CartView(
    id: 'cart-1',
    currencyCode: 'SAR',
    itemCount: 0,
    items: <CartItemView>[],
    totals: CartTotalsView(
      subtotal: MoneyView(amount: 0, currencyCode: 'SAR', formatted: '0 ر.س'),
      grandTotal: MoneyView(amount: 0, currencyCode: 'SAR', formatted: '0 ر.س'),
    ),
    checkout: CheckoutStateView(
      ready: false,
      blockers: <String>[
        'cart_empty',
        'shipping_address_missing',
        'billing_address_missing',
        'shipping_method_missing',
        'payment_method_missing',
      ],
    ),
  );

  @override
  Future<CartView> fetchCart() async {
    fetchCount += 1;
    if (fetchError != null) {
      throw fetchError!;
    }
    return _cart;
  }

  @override
  Future<CartView> addItem(AddCartItemInput input) async {
    addCount += 1;
    if (addError != null) {
      throw addError!;
    }

    final List<CartItemView> nextItems = <CartItemView>[..._cart.items];
    final int index = nextItems.indexWhere((CartItemView item) => item.sku == input.sku);
    if (index >= 0) {
      final CartItemView current = nextItems[index];
      final int nextQuantity = current.quantity + input.quantity;
      nextItems[index] = current.copyWith(
        quantity: nextQuantity,
        lineTotal: _money(current.unitPrice.amount * nextQuantity),
      );
    } else {
      nextItems.add(
        CartItemView(
          itemId: 'item-${nextItems.length + 1}',
          productId: input.productId,
          sku: input.sku,
          name: input.name,
          quantity: input.quantity,
          unitPrice: input.unitPrice,
          lineTotal: _money(input.unitPrice.amount * input.quantity),
          thumbnail: input.thumbnail,
          selectedOptions: input.selectedOptions,
        ),
      );
    }

    _cart = _rebuild(nextItems);
    return _cart;
  }

  @override
  Future<CartView> updateItemQuantity(String itemId, int quantity) async {
    updateCount += 1;
    if (updateError != null) {
      throw updateError!;
    }

    final List<CartItemView> nextItems = _cart.items
        .map((CartItemView item) {
          if (item.itemId != itemId) {
            return item;
          }
          return item.copyWith(
            quantity: quantity,
            lineTotal: _money(item.unitPrice.amount * quantity),
          );
        })
        .where((CartItemView item) => item.quantity > 0)
        .toList(growable: false);
    _cart = _rebuild(nextItems);
    return _cart;
  }

  @override
  Future<CartView> removeItem(String itemId) async {
    removeCount += 1;
    if (removeError != null) {
      throw removeError!;
    }

    final List<CartItemView> nextItems = _cart.items.where((CartItemView item) => item.itemId != itemId).toList(growable: false);
    _cart = _rebuild(nextItems);
    return _cart;
  }

  @override
  Future<CartView> assignAddresses(CartAddressAssignmentInput input) async {
    assignAddressCount += 1;
    if (assignAddressesError != null) {
      throw assignAddressesError!;
    }

    _cart = _withCheckout(
      shippingAddress: input.shippingAddress,
      billingAddress: input.sameAsShipping ? input.shippingAddress : input.billingAddress,
      selectedShippingMethod: null,
      selectedPaymentMethod: null,
    );
    _shippingMethods = _shippingMethods
        .map((ShippingMethodView method) => method.copyWith(selected: false))
        .toList(growable: false);
    _paymentMethods = _paymentMethods
        .map((PaymentMethodView method) => method.copyWith(selected: false))
        .toList(growable: false);
    return _cart;
  }

  @override
  Future<List<ShippingMethodView>> listShippingMethods() async {
    listShippingMethodsCount += 1;
    if (listShippingMethodsError != null) {
      throw listShippingMethodsError!;
    }

    if (_cart.shippingAddress == null) {
      return const <ShippingMethodView>[];
    }
    return List<ShippingMethodView>.unmodifiable(_shippingMethods);
  }

  @override
  Future<CartView> selectShippingMethod({
    required String carrierCode,
    required String methodCode,
  }) async {
    selectShippingMethodCount += 1;
    if (selectShippingMethodError != null) {
      throw selectShippingMethodError!;
    }

    final String key = '$carrierCode::$methodCode';
    ShippingMethodView? selected;
    for (final ShippingMethodView method in _shippingMethods) {
      if (method.key == key) {
        selected = method;
        break;
      }
    }
    if (selected == null) {
      throw StateError('shipping method not found');
    }

    _shippingMethods = _shippingMethods
        .map((ShippingMethodView method) => method.copyWith(selected: method.key == key))
        .toList(growable: false);
    _paymentMethods = _paymentMethods
        .map((PaymentMethodView method) => method.copyWith(selected: false))
        .toList(growable: false);
    _cart = _withCheckout(
      shippingAddress: _cart.shippingAddress,
      billingAddress: _cart.billingAddress,
      selectedShippingMethod: selected.copyWith(selected: true),
      selectedPaymentMethod: null,
    );
    return _cart;
  }

  @override
  Future<List<PaymentMethodView>> listPaymentMethods() async {
    listPaymentMethodsCount += 1;
    if (listPaymentMethodsError != null) {
      throw listPaymentMethodsError!;
    }

    if (_cart.selectedShippingMethod == null) {
      return const <PaymentMethodView>[];
    }
    return List<PaymentMethodView>.unmodifiable(_paymentMethods);
  }

  @override
  Future<CartView> selectPaymentMethod(String code) async {
    selectPaymentMethodCount += 1;
    if (selectPaymentMethodError != null) {
      throw selectPaymentMethodError!;
    }

    PaymentMethodView? selected;
    for (final PaymentMethodView method in _paymentMethods) {
      if (method.code == code) {
        selected = method;
        break;
      }
    }
    if (selected == null) {
      throw StateError('payment method not found');
    }

    _paymentMethods = _paymentMethods
        .map((PaymentMethodView method) => method.copyWith(selected: method.code == code))
        .toList(growable: false);
    _cart = _withCheckout(
      shippingAddress: _cart.shippingAddress,
      billingAddress: _cart.billingAddress,
      selectedShippingMethod: _cart.selectedShippingMethod,
      selectedPaymentMethod: selected.copyWith(selected: true),
    );
    return _cart;
  }

  @override
  Future<PlaceOrderResultView> placeOrder(PlaceOrderInput input) async {
    placeOrderCount += 1;
    if (placeOrderDelay != null) {
      await Future<void>.delayed(placeOrderDelay!);
    }
    if (placeOrderError != null) {
      throw placeOrderError!;
    }

    final String key = input.idempotencyKey.trim();
    if (key.isEmpty) {
      throw StateError('idempotency_key_required');
    }
    if (!input.termsAccepted) {
      throw StateError('terms_not_accepted');
    }

    final PlaceOrderResultView? existing = _placedOrdersByIdempotencyKey[key];
    if (existing != null) {
      return existing;
    }

    if (!_cart.checkout.ready) {
      throw StateError('checkout_not_ready');
    }

    _orderSequence += 1;
    final PlaceOrderResultView result = PlaceOrderResultView(
      orderNumber: 'KZ-$_orderSequence',
      status: 'placed',
    );
    _placedOrdersByIdempotencyKey[key] = result;

    _shippingMethods = _shippingMethods
        .map((ShippingMethodView method) => method.copyWith(selected: false))
        .toList(growable: false);
    _paymentMethods = _paymentMethods
        .map((PaymentMethodView method) => method.copyWith(selected: false))
        .toList(growable: false);
    _cart = _rebuild(const <CartItemView>[]);

    return result;
  }

  CartView _rebuild(List<CartItemView> items) {
    final double subtotalAmount = items.fold<double>(0, (double total, CartItemView item) => total + item.lineTotal.amount);
    final double shippingAmount = items.isEmpty ? 0 : (_cart.selectedShippingMethod?.amount.amount ?? 0);
    final double taxAmount = items.isEmpty ? 0 : subtotalAmount * 0.15;
    final double grandTotalAmount = subtotalAmount + shippingAmount + taxAmount;

    _cart = CartView(
      id: _cart.id,
      currencyCode: _cart.currencyCode,
      itemCount: items.fold<int>(0, (int total, CartItemView item) => total + item.quantity),
      items: items,
      shippingAddress: _cart.shippingAddress,
      billingAddress: _cart.billingAddress,
      selectedShippingMethod: _cart.selectedShippingMethod,
      selectedPaymentMethod: _cart.selectedPaymentMethod,
      totals: CartTotalsView(
        subtotal: _money(subtotalAmount),
        shipping: shippingAmount == 0 ? null : _money(shippingAmount),
        tax: taxAmount == 0 ? null : _money(taxAmount),
        grandTotal: _money(grandTotalAmount),
      ),
      checkout: _resolveCheckoutState(
        items: items,
        shippingAddress: _cart.shippingAddress,
        billingAddress: _cart.billingAddress,
        selectedShippingMethod: _cart.selectedShippingMethod,
        selectedPaymentMethod: _cart.selectedPaymentMethod,
      ),
    );
    return _cart;
  }

  CartView _withCheckout({
    required AddressView? shippingAddress,
    required AddressView? billingAddress,
    required ShippingMethodView? selectedShippingMethod,
    required PaymentMethodView? selectedPaymentMethod,
  }) {
    final double subtotalAmount = _cart.items.fold<double>(
      0,
      (double total, CartItemView item) => total + item.lineTotal.amount,
    );
    final double shippingAmount = _cart.items.isEmpty ? 0 : (selectedShippingMethod?.amount.amount ?? 0);
    final double taxAmount = _cart.items.isEmpty ? 0 : subtotalAmount * 0.15;
    final double grandTotalAmount = subtotalAmount + shippingAmount + taxAmount;

    _cart = CartView(
      id: _cart.id,
      currencyCode: _cart.currencyCode,
      itemCount: _cart.itemCount,
      items: _cart.items,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
      selectedShippingMethod: selectedShippingMethod,
      selectedPaymentMethod: selectedPaymentMethod,
      totals: CartTotalsView(
        subtotal: _money(subtotalAmount),
        shipping: shippingAmount == 0 ? null : _money(shippingAmount),
        tax: taxAmount == 0 ? null : _money(taxAmount),
        grandTotal: _money(grandTotalAmount),
      ),
      checkout: _resolveCheckoutState(
        items: _cart.items,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        selectedShippingMethod: selectedShippingMethod,
        selectedPaymentMethod: selectedPaymentMethod,
      ),
    );
    return _cart;
  }

  CheckoutStateView _resolveCheckoutState({
    required List<CartItemView> items,
    required AddressView? shippingAddress,
    required AddressView? billingAddress,
    required ShippingMethodView? selectedShippingMethod,
    required PaymentMethodView? selectedPaymentMethod,
  }) {
    final List<String> blockers = <String>[];
    if (items.isEmpty) {
      blockers.add('cart_empty');
    }
    if (shippingAddress == null) {
      blockers.add('shipping_address_missing');
    }
    if (billingAddress == null) {
      blockers.add('billing_address_missing');
    }
    if (selectedShippingMethod == null) {
      blockers.add('shipping_method_missing');
    }
    if (selectedPaymentMethod == null) {
      blockers.add('payment_method_missing');
    }
    return CheckoutStateView(
      ready: blockers.isEmpty,
      blockers: blockers,
    );
  }

  MoneyView _money(double amount) {
    final String normalized = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    return MoneyView(
      amount: amount,
      currencyCode: 'SAR',
      formatted: '$normalized ر.س',
    );
  }
}
