import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/features/orders/presentation/pages/order_details_page.dart';
import 'package:karaz_linen_app/features/orders/presentation/pages/orders_list_page.dart';

import '../../test_support/account_test_helpers.dart';
import '../../test_support/fake_account_repository.dart';

void main() {
  testWidgets('orders list renders requires-auth state', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const OrdersListPage(),
      ),
    );

    expect(find.text('الوصول إلى الطلبات يتطلب تسجيل الدخول'), findsOneWidget);
  });

  testWidgets('orders list renders loading state before data resolves', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(),
      authenticated: true,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const OrdersListPage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('orders list renders ready state with meta and navigates to details', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(),
      authenticated: true,
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/account/orders',
      routes: <RouteBase>[
        GoRoute(
          path: '/account/orders',
          builder: (_, __) => const OrdersListPage(),
        ),
        GoRoute(
          path: '/account/orders/:orderNumber',
          builder: (_, GoRouterState state) => OrderDetailsPage(
            orderNumber: state.pathParameters['orderNumber']!,
          ),
        ),
        GoRoute(
          path: '/auth-required',
          builder: (_, __) => const Scaffold(body: Center(child: Text('AUTH_REQUIRED_SCREEN'))),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpAndSettle();

    expect(find.text('إجمالي الطلبات'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('100000241'), findsOneWidget);

    await tester.tap(find.text('100000241'));
    await tester.pumpAndSettle();

    expect(find.text('ملخص الطلب'), findsOneWidget);
    expect(find.text('المنتجات'), findsOneWidget);
    expect(find.text('عنوان الشحن'), findsOneWidget);
  });

  testWidgets('order details renders error state when detail loading fails', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(
        orderDetailError: StateError('detail failed'),
      ),
      authenticated: true,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const OrderDetailsPage(orderNumber: '100000241'),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تعذر تحميل تفاصيل الطلب'), findsOneWidget);
  });
}
