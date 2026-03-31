import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/features/cart/presentation/pages/cart_page.dart';

import '../../test_support/account_test_helpers.dart';
import '../../test_support/fake_cart_repository.dart';

void main() {
  testWidgets('cart page renders requires-auth state and can navigate to auth-required', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: false,
      cartRepository: FakeCartRepository(),
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/cart',
      routes: <RouteBase>[
        GoRoute(
          path: '/cart',
          builder: (_, __) => const CartPage(),
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

    expect(find.text('الوصول إلى السلة يتطلب تسجيل الدخول'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'فتح شاشة الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('AUTH_REQUIRED_SCREEN'), findsOneWidget);
  });

  testWidgets('cart page renders loading state before cart snapshot resolves', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: true,
      cartRepository: FakeCartRepository(),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const CartPage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('cart page renders empty state and can navigate back to catalog', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: true,
      cartRepository: FakeCartRepository(
        cart: FakeCartRepository.emptyCart,
      ),
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/cart',
      routes: <RouteBase>[
        GoRoute(
          path: '/cart',
          builder: (_, __) => const CartPage(),
        ),
        GoRoute(
          path: '/catalog',
          builder: (_, __) => const Scaffold(body: Center(child: Text('CATALOG_SCREEN'))),
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

    expect(find.text('السلة فارغة'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'تصفح المنتجات'));
    await tester.pumpAndSettle();
    expect(find.text('CATALOG_SCREEN'), findsOneWidget);
  });

  testWidgets('cart page renders ready state and opens checkout route', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: true,
      cartRepository: FakeCartRepository(),
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/cart',
      routes: <RouteBase>[
        GoRoute(
          path: '/cart',
          builder: (_, __) => const CartPage(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (_, __) => const Scaffold(body: Center(child: Text('CHECKOUT_SCREEN'))),
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

    expect(find.text('سلة المشتريات'), findsOneWidget);
    expect(find.text('طقم سرير سيرين'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'بدء checkout'));
    await tester.pumpAndSettle();
    expect(find.text('CHECKOUT_SCREEN'), findsOneWidget);
  });

  testWidgets('cart page renders error state when loading fails', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: true,
      cartRepository: FakeCartRepository(
        fetchError: StateError('cart failed'),
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const CartPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تعذر تحميل السلة'), findsOneWidget);
  });
}
