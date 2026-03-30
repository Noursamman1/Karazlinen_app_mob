import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/features/catalog/application/catalog_controller.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_query.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_state.dart';

void main() {
  test('catalog filters update query and sort independently', () {
    const CatalogFilterState filters = CatalogFilterState();
    final CatalogFilterState next = filters.copyWith(
      query: 'linen',
      sort: CatalogSortOption.priceDesc,
    );

    expect(next.query, 'linen');
    expect(next.sort, CatalogSortOption.priceDesc);
  });

  test('catalog filters toggle selected values per group', () {
    const CatalogFilterState filters = CatalogFilterState();

    final CatalogFilterState selected = filters.toggleFilter('material', 'قطن');
    final CatalogFilterState unselected = selected.toggleFilter('material', 'قطن');

    expect(selected.selectedFilters['material'], contains('قطن'));
    expect(unselected.selectedFilters.containsKey('material'), isFalse);
  });

  test('catalog active filter count reflects current selections', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(catalogFilterProvider.notifier).state = container.read(catalogFilterProvider)
        .toggleFilter('material', 'قطن')
        .toggleFilter('collection', 'Serene');

    expect(container.read(catalogActiveFilterCountProvider), 2);

    container.read(catalogFilterProvider.notifier).state = container.read(catalogFilterProvider).copyWith(
          selectedFilters: const <String, Set<String>>{},
        );

    expect(container.read(catalogActiveFilterCountProvider), 0);
  });
}
