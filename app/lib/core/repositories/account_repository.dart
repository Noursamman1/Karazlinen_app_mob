import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';

abstract class AccountRepository {
  Future<ProfileView> fetchProfile();
  Future<List<AddressView>> fetchAddresses();
  Future<OrdersListingView> fetchOrders();
  Future<OrderDetailView> fetchOrderDetail(String orderNumber);
}

class DemoAccountRepository implements AccountRepository {
  const DemoAccountRepository();

  @override
  Future<List<AddressView>> fetchAddresses() async {
    return const <AddressView>[
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
  }

  @override
  Future<OrderDetailView> fetchOrderDetail(String orderNumber) async {
    return OrderDetailView(
      orderNumber: orderNumber,
      placedAt: DateTime.utc(2026, 3, 10),
      statusCode: 'processing',
      statusLabel: 'قيد التجهيز',
      grandTotal: const MoneyView(amount: 648, currencyCode: 'SAR', formatted: '648 ر.س'),
      shippingAddress: (await fetchAddresses()).first,
      billingAddress: (await fetchAddresses()).first,
      items: const <OrderItemView>[
        OrderItemView(
          sku: 'KL-100',
          name: 'طقم سرير سيرين',
          quantity: 1,
          total: MoneyView(amount: 399, currencyCode: 'SAR', formatted: '399 ر.س'),
        ),
        OrderItemView(
          sku: 'KL-102',
          name: 'منشفة سيغنتشر',
          quantity: 2,
          total: MoneyView(amount: 249, currencyCode: 'SAR', formatted: '249 ر.س'),
        ),
      ],
    );
  }

  @override
  Future<OrdersListingView> fetchOrders() async {
    final List<OrderSummaryView> items = <OrderSummaryView>[
      OrderSummaryView(
        orderNumber: '100000241',
        placedAt: DateTime(2026, 3, 10),
        statusCode: 'processing',
        statusLabel: 'قيد التجهيز',
        grandTotal: MoneyView(amount: 648, currencyCode: 'SAR', formatted: '648 ر.س'),
      ),
      OrderSummaryView(
        orderNumber: '100000198',
        placedAt: DateTime(2026, 2, 28),
        statusCode: 'complete',
        statusLabel: 'مكتمل',
        grandTotal: MoneyView(amount: 520, currencyCode: 'SAR', formatted: '520 ر.س'),
      ),
    ];

    return OrdersListingView(
      items: items,
      meta: OrdersPageMeta(
        page: 1,
        pageSize: 10,
        totalItems: items.length,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ProfileView> fetchProfile() async {
    return const ProfileView(
      customerId: 'cust-1',
      firstName: 'نورة',
      lastName: 'التميمي',
      email: 'noura@example.com',
      phone: '+966500000000',
    );
  }
}
