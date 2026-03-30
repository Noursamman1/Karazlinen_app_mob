import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/orders/application/orders_controller.dart';
import 'package:karaz_linen_app/test/test_support/fake_account_repository.dart';

void main() {
  ProviderContainer createContainer(FakeAccountRepository repository) {
    return ProviderContainer(
      overrides: <Override>[
        accountRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  test('orders state requires sign-in without fetching protected data', () {
    final FakeAccountRepository repository = FakeAccountRepository();
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    final ProtectedAsyncState<OrdersListingView> state = container.read(ordersStateProvider);

    expect(state.status, ProtectedAsyncStatus.requiresAuth);
    expect(repository.ordersFetchCount, 0);
  });

  test('orders state becomes ready for authenticated sessions', () async {
    final FakeAccountRepository repository = FakeAccountRepository();
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );

    expect(
      container.read(ordersStateProvider).status,
      ProtectedAsyncStatus.loading,
    );

    await container.read(ordersProvider.future);

    final ProtectedAsyncState<OrdersListingView> state = container.read(ordersStateProvider);

    expect(state.status, ProtectedAsyncStatus.ready);
    expect(state.data?.items, hasLength(1));
    expect(state.data?.meta.totalItems, 1);
    expect(repository.ordersFetchCount, 1);
  });

  test('orders state becomes empty when no orders are available', () async {
    final FakeAccountRepository repository = FakeAccountRepository(
      ordersListing: const OrdersListingView(
        items: <OrderSummaryView>[],
        meta: OrdersPageMeta(page: 1, pageSize: 10, totalItems: 0, totalPages: 1),
      ),
    );
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );

    await container.read(ordersProvider.future);

    final ProtectedAsyncState<OrdersListingView> state = container.read(ordersStateProvider);

    expect(state.status, ProtectedAsyncStatus.empty);
    expect(state.message, 'لا يوجد سجل طلبات بعد.');
  });

  test('order detail state surfaces repository errors', () async {
    final FakeAccountRepository repository = FakeAccountRepository(
      orderDetailError: StateError('order detail failed'),
    );
    final ProviderContainer container = createContainer(repository);
    addTearDown(container.dispose);

    container.read(sessionControllerProvider.notifier).restorePreviewSession(
          FakeAccountRepository.sampleProfile,
        );

    await expectLater(
      container.read(orderDetailProvider('100000241').future),
      throwsA(isA<StateError>()),
    );

    final ProtectedAsyncState<OrderDetailView> state = container.read(
      orderDetailStateProvider('100000241'),
    );

    expect(state.status, ProtectedAsyncStatus.error);
    expect(state.message, 'تعذر تحميل تفاصيل الطلب');
  });
}
