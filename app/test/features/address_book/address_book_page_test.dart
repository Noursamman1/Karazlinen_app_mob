import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/features/address_book/presentation/pages/address_book_page.dart';
import 'package:karaz_linen_app/features/address_book/presentation/pages/address_form_page.dart';

import '../../test_support/account_test_helpers.dart';
import '../../test_support/fake_account_repository.dart';

void main() {
  testWidgets('address book renders requires-auth state', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const AddressBookPage(),
      ),
    );

    expect(find.text('الوصول إلى العناوين يتطلب تسجيل الدخول'), findsOneWidget);
  });

  testWidgets('address book renders loading state before addresses resolve', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(),
      authenticated: true,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const AddressBookPage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('address book empty state can navigate to add-address baseline form', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(
        addresses: const <AddressView>[],
      ),
      authenticated: true,
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/account/addresses',
      routes: <RouteBase>[
        GoRoute(
          path: '/account/addresses',
          builder: (_, __) => const AddressBookPage(),
        ),
        GoRoute(
          path: '/account/addresses/new',
          builder: (_, GoRouterState state) => AddressFormPage(
            initialAddress: state.extra is AddressView ? state.extra! as AddressView : null,
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

    expect(find.text('لا توجد عناوين محفوظة بعد'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'إضافة عنوان جديد'));
    await tester.pumpAndSettle();

    expect(find.text('إعداد عنوان جديد'), findsOneWidget);
    expect(find.text('الحفظ سيتفعّل عند ربط الـBFF'), findsOneWidget);
  });

  testWidgets('address book ready state can navigate to edit-address baseline form', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(),
      authenticated: true,
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/account/addresses',
      routes: <RouteBase>[
        GoRoute(
          path: '/account/addresses',
          builder: (_, __) => const AddressBookPage(),
        ),
        GoRoute(
          path: '/account/addresses/new',
          builder: (_, GoRouterState state) => AddressFormPage(
            initialAddress: state.extra is AddressView ? state.extra! as AddressView : null,
          ),
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

    expect(find.text('افتراضي للشحن'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'تعديل العنوان'));
    await tester.pumpAndSettle();

    expect(find.text('تعديل العنوان'), findsOneWidget);
    expect(find.text('هذا العنوان مميز حاليًا كعنوان افتراضي للشحن'), findsOneWidget);
  });

  testWidgets('address book renders error state when loading fails', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      repository: FakeAccountRepository(
        addressesError: StateError('addresses failed'),
      ),
      authenticated: true,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const AddressBookPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تعذر تحميل العناوين'), findsOneWidget);
  });
}
