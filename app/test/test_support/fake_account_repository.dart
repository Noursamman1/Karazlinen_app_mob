import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/core/repositories/account_repository.dart';

class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository({
    ProfileView? profile,
    List<AddressView>? addresses,
    OrdersListingView? ordersListing,
    OrderDetailView? orderDetail,
    this.profileError,
    this.addressesError,
    this.ordersError,
    this.orderDetailError,
  })  : profile = profile ?? sampleProfile,
        addresses = addresses ?? sampleAddresses,
        ordersListing = ordersListing ?? sampleOrdersListing,
        orderDetail = orderDetail ?? sampleOrderDetail;

  final ProfileView profile;
  final List<AddressView> addresses;
  final OrdersListingView ordersListing;
  final OrderDetailView orderDetail;
  final Object? profileError;
  final Object? addressesError;
  final Object? ordersError;
  final Object? orderDetailError;
  int profileFetchCount = 0;
  int addressesFetchCount = 0;
  int ordersFetchCount = 0;
  int orderDetailFetchCount = 0;

  static const ProfileView sampleProfile = ProfileView(
    customerId: 'cust-1',
    firstName: 'نورة',
    lastName: 'التميمي',
    email: 'noura@example.com',
    phone: '+966500000000',
  );

  static const List<AddressView> sampleAddresses = <AddressView>[
    AddressView(
      id: 'addr-1',
      firstName: 'نورة',
      lastName: 'التميمي',
      phone: '+966500000000',
      country: 'SA',
      city: 'الرياض',
      region: 'الرياض',
      streetLines: <String>['حي الندى', 'شارع الأمير محمد بن سعد'],
      postcode: '13317',
      isDefaultBilling: true,
      isDefaultShipping: true,
    ),
  ];

  static final OrdersListingView sampleOrdersListing = OrdersListingView(
    items: <OrderSummaryView>[
      OrderSummaryView(
        orderNumber: '100000241',
        placedAt: DateTime.utc(2026, 3, 10),
        statusCode: 'processing',
        statusLabel: 'قيد التجهيز',
        grandTotal: MoneyView(amount: 648, currencyCode: 'SAR', formatted: '648 ر.س'),
      ),
    ],
    meta: OrdersPageMeta(
      page: 1,
      pageSize: 10,
      totalItems: 1,
      totalPages: 1,
    ),
  );

  static final OrderDetailView sampleOrderDetail = OrderDetailView(
    orderNumber: '100000241',
    placedAt: DateTime.utc(2026, 3, 10),
    statusCode: 'processing',
    statusLabel: 'قيد التجهيز',
    grandTotal: const MoneyView(amount: 648, currencyCode: 'SAR', formatted: '648 ر.س'),
    shippingAddress: sampleAddresses.first,
    billingAddress: sampleAddresses.first,
    items: const <OrderItemView>[
      OrderItemView(
        sku: 'KL-100',
        name: 'طقم سرير سيرين',
        quantity: 1,
        total: MoneyView(amount: 399, currencyCode: 'SAR', formatted: '399 ر.س'),
      ),
    ],
  );

  @override
  Future<List<AddressView>> fetchAddresses() async {
    addressesFetchCount += 1;
    if (addressesError != null) {
      throw addressesError!;
    }
    return addresses;
  }

  @override
  Future<OrderDetailView> fetchOrderDetail(String orderNumber) async {
    orderDetailFetchCount += 1;
    if (orderDetailError != null) {
      throw orderDetailError!;
    }
    return orderDetail;
  }

  @override
  Future<OrdersListingView> fetchOrders() async {
    ordersFetchCount += 1;
    if (ordersError != null) {
      throw ordersError!;
    }
    return ordersListing;
  }

  @override
  Future<ProfileView> fetchProfile() async {
    profileFetchCount += 1;
    if (profileError != null) {
      throw profileError!;
    }
    return profile;
  }
}
