import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/catalog/application/catalog_controller.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_result.dart';
import 'package:karaz_linen_app/features/catalog/presentation/pages/catalog_page.dart';

import '../../test_support/fake_catalog_repository.dart';

void main() {
  test('default catalog sort is featured', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(catalogSortProvider), 'featured');
  });

  testWidgets('catalog page renders loading state before data resolves', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ],
        child: const MaterialApp(home: CatalogPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('catalog page renders empty state when listing is empty', (WidgetTester tester) async {
    const CatalogProductListing emptyListing = CatalogProductListing(
      items: <ProductSummaryView>[],
      meta: CatalogPageMeta(page: 1, pageSize: 24, totalItems: 0, totalPages: 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(
            FakeCatalogRepository(listing: emptyListing),
          ),
        ],
        child: const MaterialApp(home: CatalogPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('لا توجد منتجات مطابقة الآن. جرّبي تعديل التصفية أو البحث.'), findsOneWidget);
  });

  testWidgets('catalog page renders product error state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(
            FakeCatalogRepository(listingError: Exception('listing failed')),
          ),
        ],
        child: const MaterialApp(home: CatalogPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تعذر تحميل المنتجات'), findsOneWidget);
  });
}
