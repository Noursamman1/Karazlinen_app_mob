import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/features/account/presentation/pages/account_overview_page.dart';

import '../../test_support/account_test_helpers.dart';
import '../../test_support/fake_account_repository.dart';

void main() {
  testWidgets('account overview renders requires-auth state and navigates to auth-required', (
    WidgetTester tester,
  ) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(),
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/account',
      routes: <RouteBase>[
        GoRoute(
          path: '/account',
          builder: (_, __) => const AccountOverviewPage(),
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

    expect(find.text('الوصول إلى الحساب يتطلب تسجيل الدخول'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'فتح شاشة الدخول'));
    await tester.pumpAndSettle();

    expect(find.text('AUTH_REQUIRED_SCREEN'), findsOneWidget);
  });

  testWidgets('account overview renders loading state before profile resolves', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(),
      authenticated: true,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const AccountOverviewPage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('account overview renders authenticated profile and quick access', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(),
      authenticated: true,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const AccountOverviewPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('مرحبًا، نورة'), findsOneWidget);
    expect(find.text('العناوين'), findsWidgets);
    expect(find.text('الطلبات'), findsWidgets);
  });

  testWidgets('account overview renders error state when profile load fails', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(
        profileError: StateError('profile failed'),
      ),
      authenticated: true,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const AccountOverviewPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تعذر تحميل الملف الشخصي'), findsOneWidget);
  });
}
