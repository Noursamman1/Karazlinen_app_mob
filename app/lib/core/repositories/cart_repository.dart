import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';

abstract class CartRepository {
  Future<CartView> fetchCart();
  Future<CartView> addItem(AddCartItemInput input);
  Future<CartView> updateItemQuantity(String itemId, int quantity);
  Future<CartView> removeItem(String itemId);
  Future<CartView> assignAddresses(CartAddressAssignmentInput input);
  Future<List<ShippingMethodView>> listShippingMethods();
  Future<CartView> selectShippingMethod({
    required String carrierCode,
    required String methodCode,
  });
  Future<List<PaymentMethodView>> listPaymentMethods();
  Future<CartView> selectPaymentMethod(String code);
  Future<PlaceOrderResultView> placeOrder(PlaceOrderInput input);
}

class DemoCartRepository implements CartRepository {
  DemoCartRepository();

  final List<CartItemView> _items = <CartItemView>[];
  int _sequence = 0;
  final String _cartId = 'demo-cart-1';
  static const String _currencyCode = 'SAR';
  static final List<ShippingMethodView> _baseShippingMethods = <ShippingMethodView>[
    ShippingMethodView(
      carrierCode: 'flat_rate',
      methodCode: 'standard',
      label: 'توصيل قياسي',
      detail: 'التوصيل خلال 3-5 أيام عمل',
      amount: _moneyStatic(35),
      selected: false,
    ),
    ShippingMethodView(
      carrierCode: 'express',
      methodCode: 'next_day',
      label: 'توصيل سريع',
      detail: 'التوصيل خلال يوم عمل',
      amount: _moneyStatic(55),
      selected: false,
    ),
  ];
  static final List<PaymentMethodView> _basePaymentMethods = <PaymentMethodView>[
    const PaymentMethodView(
      code: 'cashondelivery',
      label: 'الدفع عند الاستلام',
      detail: 'الدفع نقدًا عند الاستلام',
      selected: false,
    ),
    const PaymentMethodView(
      code: 'banktransfer',
      label: 'تحويل بنكي',
      detail: 'تحويل إلى حساب الشركة',
      selected: false,
    ),
  ];

  AddressView? _shippingAddress;
  AddressView? _billingAddress;
  String? _selectedShippingMethodKey;
  String? _selectedPaymentMethodCode;
  final Map<String, PlaceOrderResultView> _placedOrdersByIdempotencyKey = <String, PlaceOrderResultView>{};
  int _orderSequence = 100050;

  @override
  Future<CartView> fetchCart() async {
    return _snapshot();
  }

  @override
  Future<CartView> addItem(AddCartItemInput input) async {
    final int existingIndex = _items.indexWhere((CartItemView item) {
      return item.sku == input.sku && _optionKey(item.selectedOptions) == _optionKey(input.selectedOptions);
    });

    if (existingIndex >= 0) {
      final CartItemView current = _items[existingIndex];
      final int nextQuantity = current.quantity + input.quantity;
      _items[existingIndex] = current.copyWith(
        quantity: nextQuantity,
        lineTotal: _money(current.unitPrice.amount * nextQuantity),
      );
      return _snapshot();
    }

    _sequence += 1;
    final CartItemView next = CartItemView(
      itemId: 'item-$_sequence',
      productId: input.productId,
      sku: input.sku,
      name: input.name,
      quantity: input.quantity,
      unitPrice: input.unitPrice,
      lineTotal: _money(input.unitPrice.amount * input.quantity),
      thumbnail: input.thumbnail,
      selectedOptions: input.selectedOptions,
    );
    _items.add(next);
    return _snapshot();
  }

  @override
  Future<CartView> updateItemQuantity(String itemId, int quantity) async {
    final int index = _items.indexWhere((CartItemView item) => item.itemId == itemId);
    if (index < 0) {
      return _snapshot();
    }
    final CartItemView current = _items[index];
    _items[index] = current.copyWith(
      quantity: quantity,
      lineTotal: _money(current.unitPrice.amount * quantity),
    );
    return _snapshot();
  }

  @override
  Future<CartView> removeItem(String itemId) async {
    _items.removeWhere((CartItemView item) => item.itemId == itemId);
    return _snapshot();
  }

  @override
  Future<CartView> assignAddresses(CartAddressAssignmentInput input) async {
    _shippingAddress = input.shippingAddress;
    _billingAddress = input.sameAsShipping ? input.shippingAddress : input.billingAddress;
    return _snapshot();
  }

  @override
  Future<List<ShippingMethodView>> listShippingMethods() async {
    if (_shippingAddress == null) {
      return const <ShippingMethodView>[];
    }

    return _baseShippingMethods
        .map(
          (ShippingMethodView method) => method.copyWith(
            selected: method.key == _selectedShippingMethodKey,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<CartView> selectShippingMethod({
    required String carrierCode,
    required String methodCode,
  }) async {
    final String key = '$carrierCode::$methodCode';
    final List<ShippingMethodView> methods = await listShippingMethods();
    final bool exists = methods.any((ShippingMethodView method) => method.key == key);
    if (!exists) {
      throw StateError('shipping_method_unavailable');
    }

    _selectedShippingMethodKey = key;
    return _snapshot();
  }

  @override
  Future<List<PaymentMethodView>> listPaymentMethods() async {
    if (_shippingAddress == null || _selectedShippingMethodKey == null) {
      return const <PaymentMethodView>[];
    }

    return _basePaymentMethods
        .map(
          (PaymentMethodView method) => method.copyWith(
            selected: method.code == _selectedPaymentMethodCode,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<CartView> selectPaymentMethod(String code) async {
    final List<PaymentMethodView> methods = await listPaymentMethods();
    final bool exists = methods.any((PaymentMethodView method) => method.code == code);
    if (!exists) {
      throw StateError('payment_method_unavailable');
    }

    _selectedPaymentMethodCode = code;
    return _snapshot();
  }

  @override
  Future<PlaceOrderResultView> placeOrder(PlaceOrderInput input) async {
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

    final CartView current = _snapshot();
    if (!current.checkout.ready) {
      throw StateError('checkout_not_ready');
    }

    _orderSequence += 1;
    final PlaceOrderResultView result = PlaceOrderResultView(
      orderNumber: 'KZ-$_orderSequence',
      status: 'placed',
    );
    _placedOrdersByIdempotencyKey[key] = result;

    _items.clear();
    _selectedShippingMethodKey = null;
    _selectedPaymentMethodCode = null;
    return result;
  }

  CartView _snapshot() {
    final double subtotalAmount = _items.fold<double>(
      0,
      (double total, CartItemView item) => total + item.lineTotal.amount,
    );
    final ShippingMethodView? selectedShippingMethod = _resolvedShippingMethod();
    final PaymentMethodView? selectedPaymentMethod = _resolvedPaymentMethod();
    final double shippingAmount = _items.isEmpty ? 0 : (selectedShippingMethod?.amount.amount ?? 0);
    final double taxAmount = _items.isEmpty ? 0 : subtotalAmount * 0.15;
    final double grandTotalAmount = subtotalAmount + shippingAmount + taxAmount;

    return CartView(
      id: _cartId,
      currencyCode: _currencyCode,
      itemCount: _items.fold<int>(
        0,
        (int total, CartItemView item) => total + item.quantity,
      ),
      items: List<CartItemView>.unmodifiable(_items),
      shippingAddress: _shippingAddress,
      billingAddress: _billingAddress,
      selectedShippingMethod: selectedShippingMethod,
      selectedPaymentMethod: selectedPaymentMethod,
      totals: CartTotalsView(
        subtotal: _money(subtotalAmount),
        shipping: shippingAmount == 0 ? null : _money(shippingAmount),
        tax: taxAmount == 0 ? null : _money(taxAmount),
        grandTotal: _money(grandTotalAmount),
      ),
      checkout: CheckoutStateView(
        ready: _checkoutBlockers.isEmpty,
        blockers: List<String>.unmodifiable(_checkoutBlockers),
      ),
    );
  }

  String _optionKey(List<CartSelectedOptionView> options) {
    if (options.isEmpty) {
      return '';
    }
    final List<String> parts = options
        .map((CartSelectedOptionView option) => '${option.code}:${option.value}')
        .toList(growable: false)
      ..sort();
    return parts.join('|');
  }

  MoneyView _money(double amount) {
    final String normalized = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    return MoneyView(
      amount: amount,
      currencyCode: _currencyCode,
      formatted: '$normalized ر.س',
    );
  }

  List<String> get _checkoutBlockers {
    final List<String> blockers = <String>[];
    if (_items.isEmpty) {
      blockers.add('cart_empty');
    }
    if (_shippingAddress == null) {
      blockers.add('shipping_address_missing');
    }
    if (_billingAddress == null) {
      blockers.add('billing_address_missing');
    }
    if (_selectedShippingMethodKey == null) {
      blockers.add('shipping_method_missing');
    }
    if (_selectedPaymentMethodCode == null) {
      blockers.add('payment_method_missing');
    }
    return blockers;
  }

  ShippingMethodView? _resolvedShippingMethod() {
    if (_selectedShippingMethodKey == null) {
      return null;
    }

    for (final ShippingMethodView method in _baseShippingMethods) {
      if (method.key == _selectedShippingMethodKey) {
        return method.copyWith(selected: true);
      }
    }
    return null;
  }

  PaymentMethodView? _resolvedPaymentMethod() {
    if (_selectedPaymentMethodCode == null) {
      return null;
    }

    for (final PaymentMethodView method in _basePaymentMethods) {
      if (method.code == _selectedPaymentMethodCode) {
        return method.copyWith(selected: true);
      }
    }
    return null;
  }

  static MoneyView _moneyStatic(double amount) {
    final String normalized = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    return MoneyView(
      amount: amount,
      currencyCode: _currencyCode,
      formatted: '$normalized ر.س',
    );
  }
}
