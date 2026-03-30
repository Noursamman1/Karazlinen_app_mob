import 'package:karaz_linen_app/core/models/commerce_models.dart';

class ProfileView {
  const ProfileView({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
  });

  final String customerId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;

  String get fullName => '$firstName $lastName';
}

class AddressView {
  const AddressView({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.country,
    required this.city,
    required this.streetLines,
    required this.postcode,
    required this.isDefaultBilling,
    required this.isDefaultShipping,
    this.region,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String country;
  final String city;
  final String? region;
  final List<String> streetLines;
  final String postcode;
  final bool isDefaultBilling;
  final bool isDefaultShipping;
}

class OrderItemView {
  const OrderItemView({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.total,
  });

  final String sku;
  final String name;
  final int quantity;
  final MoneyView total;
}

class OrderSummaryView {
  const OrderSummaryView({
    required this.orderNumber,
    required this.placedAt,
    required this.statusCode,
    required this.statusLabel,
    required this.grandTotal,
  });

  final String orderNumber;
  final DateTime placedAt;
  final String statusCode;
  final String statusLabel;
  final MoneyView grandTotal;
}

class OrdersPageMeta {
  const OrdersPageMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
}

class OrdersListingView {
  const OrdersListingView({
    required this.items,
    required this.meta,
  });

  final List<OrderSummaryView> items;
  final OrdersPageMeta meta;
}

class OrderDetailView extends OrderSummaryView {
  const OrderDetailView({
    required super.orderNumber,
    required super.placedAt,
    required super.statusCode,
    required super.statusLabel,
    required super.grandTotal,
    required this.items,
    this.shippingAddress,
    this.billingAddress,
  });

  final AddressView? shippingAddress;
  final AddressView? billingAddress;
  final List<OrderItemView> items;
}
