import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';

final ordersProvider = FutureProvider<List<OrderSummaryView>>((Ref ref) {
  return ref.watch(accountRepositoryProvider).fetchOrders();
});

final orderDetailProvider = FutureProvider.family<OrderDetailView, String>((Ref ref, String orderNumber) {
  return ref.watch(accountRepositoryProvider).fetchOrderDetail(orderNumber);
});
