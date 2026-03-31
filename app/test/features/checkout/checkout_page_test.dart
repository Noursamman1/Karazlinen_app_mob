import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/models/cart_models.dart';
import 'package:karaz_linen_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:karaz_linen_app/test/test_support/account_test_helpers.dart';
import 'package:karaz_linen_app/test/test_support/fake_account_repository.dart';
import 'package:karaz_linen_app/test/test_support/fake_cart_repository.dart';

void main() {
  testWidgets('checkout page renders requires-auth state', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: false,
      repository: FakeAccountRepository(),
      cartRepository: FakeCartRepository(
        cart: FakeCartRepository.readyCheckoutCart,
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const CheckoutPage(),
      ),
    );

    expect(find.text('الوصول إلى checkout يتطلب تسجيل الدخول'), findsOneWidget);
  });

  testWidgets('checkout page renders loading state before cart resolves', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: true,
      repository: FakeAccountRepository(),
      cartRepository: FakeCartRepository(),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const CheckoutPage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('checkout page renders empty state and can return to cart', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: true,
      repository: FakeAccountRepository(),
      cartRepository: FakeCartRepository(
        cart: FakeCartRepository.emptyCart,
      ),
    );
    addTearDown(container.dispose);

    final GoRouter router = GoRouter(
      initialLocation: '/checkout',
      routes: <RouteBase>[
        GoRoute(
          path: '/checkout',
          builder: (_, __) => const CheckoutPage(),
        ),
        GoRoute(
          path: '/cart',
          builder: (_, __) => const Scaffold(body: Center(child: Text('CART_SCREEN'))),
        ),
      ],
    );

    await tester.pumpWidget(
      buildRoutedTestApp(
        container: container,
        router: router,
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpAndSettle();

    expect(find.text('السلة فارغة'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'العودة إلى السلة'));
    await tester.pumpAndSettle();
    expect(find.text('CART_SCREEN'), findsOneWidget);
  });

  testWidgets('checkout transitions across address, shipping, and payment steps', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: true,
      repository: FakeAccountRepository(),
      cartRepository: FakeCartRepository(),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const CheckoutPage(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('الرياض').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'حفظ العناوين'));
    await tester.pumpAndSettle();
    expect(find.text('توصيل قياسي'), findsOneWidget);

    await tester.tap(find.text('توصيل قياسي').first);
    await tester.pumpAndSettle();
    expect(find.text('الدفع عند الاستلام'), findsOneWidget);

    await tester.tap(find.text('الدفع عند الاستلام').first);
    await tester.pumpAndSettle();
    expect(find.text('حالة الجاهزية'), findsOneWidget);
  });

  testWidgets('terms acceptance controls place-order CTA enablement', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: true,
      repository: FakeAccountRepository(),
      cartRepository: FakeCartRepository(
        cart: FakeCartRepository.readyCheckoutCart,
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const CheckoutPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('المراجعة'));
    await tester.pumpAndSettle();

    FilledButton button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'تأكيد الطلب'),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'تأكيد الطلب'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('checkout shows submitting then success states on place-order', (WidgetTester tester) async {
    final container = createAccountTestContainer(
      authenticated: true,
      repository: FakeAccountRepository(),
      cartRepository: FakeCartRepository(
        cart: FakeCartRepository.readyCheckoutCart,
        placeOrderDelay: const Duration(milliseconds: 120),
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const CheckoutPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('المراجعة'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'تأكيد الطلب'));
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.text('تم إرسال الطلب بنجاح'), findsOneWidget);
    expect(find.textContaining('رقم الطلب: KZ-'), findsOneWidget);
  });

  testWidgets('checkout shows failure then succeeds on retry with same idempotency key', (WidgetTester tester) async {
    final _RetryingFakeCartRepository repository = _RetryingFakeCartRepository();
    final container = createAccountTestContainer(
      authenticated: true,
      repository: FakeAccountRepository(),
      cartRepository: repository,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      buildAccountTestApp(
        container: container,
        child: const CheckoutPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('المراجعة'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'تأكيد الطلب'));
    await tester.pumpAndSettle();
    expect(find.text('خدمة الطلبات غير متاحة حاليًا، حاولي مرة أخرى لاحقًا.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.text('تم إرسال الطلب بنجاح'), findsOneWidget);

    expect(repository.idempotencyKeys, hasLength(2));
    expect(repository.idempotencyKeys.first, repository.idempotencyKeys.last);
  });
}

class _RetryingFakeCartRepository extends FakeCartRepository {
  _RetryingFakeCartRepository()
      : super(
          cart: FakeCartRepository.readyCheckoutCart,
        );

  bool _failedOnce = false;
  final List<String> idempotencyKeys = <String>[];

  @override
  Future<PlaceOrderResultView> placeOrder(PlaceOrderInput input) async {
    idempotencyKeys.add(input.idempotencyKey);
    if (!_failedOnce) {
      _failedOnce = true;
      throw StateError('upstream unavailable');
    }
    return super.placeOrder(input);
  }
}

Widget buildRoutedTestApp({
  required ProviderContainer container,
  required GoRouter router,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}
