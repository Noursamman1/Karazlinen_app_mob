import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/product/presentation/pages/product_details_page.dart';

import '../../test_support/fake_catalog_repository.dart';

void main() {
  testWidgets('product details page renders loading state first', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ],
        child: const MaterialApp(home: ProductDetailsPage(productId: 'sku-100')),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('product CTA stays disabled for incomplete selection', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ],
        child: const MaterialApp(home: ProductDetailsPage(productId: 'sku-100')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('الخيارات الناقصة: المقاس، اللون'), findsOneWidget);

    final FilledButton button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('product page resolves matching variant and enables CTA', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ],
        child: const MaterialApp(home: ProductDetailsPage(productId: 'sku-100')),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'كوين'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'رملي'));
    await tester.pumpAndSettle();

    expect(find.text('النسخة المختارة جاهزة'), findsOneWidget);
    expect(find.text('SKU الحالي: KL-100-Q-SND'), findsOneWidget);
    expect(find.text('429 ر.س'), findsOneWidget);
    expect(find.text('هذه القيم تأتي الآن من `variantResolution` المعتمد: SKU والسعر والصورة والتوفر مرتبطة بالـcombination المختار.'), findsOneWidget);

    final FilledButton button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('product page keeps guardrail fallback for non-matching selection', (WidgetTester tester) async {
    const ProductDetailView unresolvedDetail = ProductDetailView(
      id: 'sku-100',
      sku: 'KL-100',
      slug: 'serene-sheet-set',
      name: 'طقم سرير سيرين',
      subtitle: 'قطن ناعم',
      price: MoneyView(amount: 399, currencyCode: 'SAR', formatted: '399 ر.س'),
      stockStatus: 'in_stock',
      gallery: <ImageView>[],
      configurableOptions: <ConfigurableOptionView>[
        ConfigurableOptionView(
          code: 'size',
          label: 'المقاس',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'queen', label: 'كوين', available: true),
            ConfigurableValueView(value: 'king', label: 'كينغ', available: true),
          ],
        ),
        ConfigurableOptionView(
          code: 'color',
          label: 'اللون',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'sand', label: 'رملي', available: true),
            ConfigurableValueView(value: 'ivory', label: 'عاجي', available: true),
          ],
        ),
      ],
      variantResolution: VariantResolutionView(
        mode: 'resolved_combinations',
        combinations: <ResolvedVariantCombinationView>[
          ResolvedVariantCombinationView(
            selection: <String, String>{'size': 'queen', 'color': 'sand'},
            resolvedSku: 'KL-100-Q-SND',
            availability: 'in_stock',
            price: MoneyView(amount: 429, currencyCode: 'SAR', formatted: '429 ر.س'),
          ),
        ],
        unresolvedReason: 'Missing combination from BFF payload.',
      ),
      description: 'تفاصيل منتج اختباري.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(
            FakeCatalogRepository(detail: unresolvedDetail),
          ),
        ],
        child: const MaterialApp(home: ProductDetailsPage(productId: 'sku-100')),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'كينغ'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'عاجي'));
    await tester.pumpAndSettle();

    expect(find.text('الاختيار لا يطابق combination معروفًا بعد'), findsOneWidget);
    expect(find.text('تعذر اعتماد النسخة الحالية'), findsOneWidget);

    final FilledButton button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('product page renders error state when detail fails', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(
            FakeCatalogRepository(detailError: Exception('detail failed')),
          ),
        ],
        child: const MaterialApp(home: ProductDetailsPage(productId: 'sku-100')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تعذر تحميل المنتج'), findsOneWidget);
  });
}
