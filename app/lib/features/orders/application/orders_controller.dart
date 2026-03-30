import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/features/account/application/account_controller.dart';
import 'package:karaz_linen_app/features/account/application/account_use_cases.dart';
import 'package:karaz_linen_app/features/account/application/protected_state_mapper.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';

final ordersProvider = FutureProvider<OrdersListingView>((Ref ref) {
  return ref.watch(loadOrdersUseCaseProvider).call();
});

final Provider<ProtectedAsyncState<OrdersListingView>> ordersStateProvider =
    Provider<ProtectedAsyncState<OrdersListingView>>((Ref ref) {
  final access = ref.watch(accountAccessStateProvider);
  if (!access.canAccessProtectedData) {
    return ProtectedAsyncState<OrdersListingView>.requiresAuth(access.guardMessage);
  }

  return mapProtectedAsyncState<OrdersListingView>(
    access: access,
    asyncValue: ref.watch(ordersProvider),
    isEmpty: (OrdersListingView value) => value.items.isEmpty,
    emptyMessage: 'لا يوجد سجل طلبات بعد.',
    errorMessage: 'تعذر تحميل الطلبات',
  );
});

final orderDetailProvider = FutureProvider.family<OrderDetailView, String>((Ref ref, String orderNumber) {
  return ref.watch(loadOrderDetailUseCaseProvider).call(orderNumber);
});

final ProviderFamily<ProtectedAsyncState<OrderDetailView>, String> orderDetailStateProvider =
    Provider.family<ProtectedAsyncState<OrderDetailView>, String>((Ref ref, String orderNumber) {
  final access = ref.watch(accountAccessStateProvider);
  if (!access.canAccessProtectedData) {
    return ProtectedAsyncState<OrderDetailView>.requiresAuth(access.guardMessage);
  }

  return mapProtectedAsyncState<OrderDetailView>(
    access: access,
    asyncValue: ref.watch(orderDetailProvider(orderNumber)),
    isEmpty: (_) => false,
    emptyMessage: 'لا توجد تفاصيل لهذا الطلب.',
    errorMessage: 'تعذر تحميل تفاصيل الطلب',
  );
});
