import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_result.dart';
import 'package:karaz_linen_app/features/search/application/search_controller.dart';
import 'package:karaz_linen_app/features/search/presentation/pages/search_page.dart';

import '../../test_support/fake_catalog_repository.dart';

void main() {
  testWidgets('search page renders search field', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('search page renders loading state before results resolve', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('search page renders empty state when there are no matches', (WidgetTester tester) async {
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
        child: const MaterialApp(home: SearchPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('لا توجد نتائج مطابقة. جرّبي تعديل الكلمات أو الفلاتر.'), findsOneWidget);
  });

  testWidgets('search page renders error state when listing fails', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(
            FakeCatalogRepository(listingError: Exception('search failed')),
          ),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('تعذر تنفيذ البحث'), findsOneWidget);
  });

  testWidgets('search page shows active filter count after toggling a filter', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );

    await tester.pumpAndSettle();

    final Element scopeElement = tester.element(find.byType(SearchPage));
    final ProviderContainer container = ProviderScope.containerOf(scopeElement);

    container.read(searchFilterProvider.notifier).state =
        container.read(searchFilterProvider).toggleFilter('material', 'قطن');
    await tester.pumpAndSettle();

    expect(find.text('1 فلترًا مفعّلًا'), findsOneWidget);
  });
}
