import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';

class CartSelectedOptionView {
  const CartSelectedOptionView({
    required this.code,
    required this.label,
    required this.value,
  });

  final String code;
  final String label;
  final String value;
}

class CartItemView {
  const CartItemView({
    required this.itemId,
    required this.productId,
    required this.sku,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.thumbnail,
    this.selectedOptions = const <CartSelectedOptionView>[],
  });

  final String itemId;
  final String productId;
  final String sku;
  final String name;
  final int quantity;
  final MoneyView unitPrice;
  final MoneyView lineTotal;
  final ImageView? thumbnail;
  final List<CartSelectedOptionView> selectedOptions;

  CartItemView copyWith({
    int? quantity,
    MoneyView? lineTotal,
  }) {
    return CartItemView(
      itemId: itemId,
      productId: productId,
      sku: sku,
      name: name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      thumbnail: thumbnail,
      selectedOptions: selectedOptions,
    );
  }
}

class CartTotalsView {
  const CartTotalsView({
    required this.subtotal,
    required this.grandTotal,
    this.shipping,
    this.tax,
    this.discount,
  });

  final MoneyView subtotal;
  final MoneyView grandTotal;
  final MoneyView? shipping;
  final MoneyView? tax;
  final MoneyView? discount;
}

class CheckoutStateView {
  const CheckoutStateView({
    required this.ready,
    required this.blockers,
  });

  final bool ready;
  final List<String> blockers;
}

class ShippingMethodView {
  const ShippingMethodView({
    required this.carrierCode,
    required this.methodCode,
    required this.label,
    required this.amount,
    required this.selected,
    this.detail,
  });

  final String carrierCode;
  final String methodCode;
  final String label;
  final String? detail;
  final MoneyView amount;
  final bool selected;

  String get key => '$carrierCode::$methodCode';

  ShippingMethodView copyWith({
    bool? selected,
  }) {
    return ShippingMethodView(
      carrierCode: carrierCode,
      methodCode: methodCode,
      label: label,
      detail: detail,
      amount: amount,
      selected: selected ?? this.selected,
    );
  }
}

class PaymentMethodView {
  const PaymentMethodView({
    required this.code,
    required this.label,
    required this.selected,
    this.detail,
  });

  final String code;
  final String label;
  final String? detail;
  final bool selected;

  PaymentMethodView copyWith({
    bool? selected,
  }) {
    return PaymentMethodView(
      code: code,
      label: label,
      detail: detail,
      selected: selected ?? this.selected,
    );
  }
}

class CartAddressAssignmentInput {
  const CartAddressAssignmentInput({
    required this.shippingAddress,
    required this.sameAsShipping,
    this.billingAddress,
  });

  final AddressView shippingAddress;
  final bool sameAsShipping;
  final AddressView? billingAddress;
}

class CartView {
  const CartView({
    required this.id,
    required this.currencyCode,
    required this.itemCount,
    required this.items,
    required this.totals,
    required this.checkout,
    this.shippingAddress,
    this.billingAddress,
    this.selectedShippingMethod,
    this.selectedPaymentMethod,
  });

  final String id;
  final String currencyCode;
  final int itemCount;
  final List<CartItemView> items;
  final CartTotalsView totals;
  final AddressView? shippingAddress;
  final AddressView? billingAddress;
  final ShippingMethodView? selectedShippingMethod;
  final PaymentMethodView? selectedPaymentMethod;
  final CheckoutStateView checkout;
}

class AddCartItemInput {
  const AddCartItemInput({
    required this.productId,
    required this.sku,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.thumbnail,
    this.selectedOptions = const <CartSelectedOptionView>[],
  });

  final String productId;
  final String sku;
  final String name;
  final int quantity;
  final MoneyView unitPrice;
  final ImageView? thumbnail;
  final List<CartSelectedOptionView> selectedOptions;
}

class PlaceOrderInput {
  const PlaceOrderInput({
    required this.idempotencyKey,
    required this.termsAccepted,
    this.customerNote,
  });

  final String idempotencyKey;
  final bool termsAccepted;
  final String? customerNote;
}

class PlaceOrderResultView {
  const PlaceOrderResultView({
    required this.orderNumber,
    required this.status,
  });

  final String orderNumber;
  final String status;
}
