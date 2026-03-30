import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/repositories/catalog_repository.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_query.dart';

void main() {
  const DemoCatalogRepository repository = DemoCatalogRepository();

  test('catalog listing returns canonical pagination and derived filters', () async {
    final listing = await repository.fetchProductListing(
      const CatalogProductQuery(
        categoryId: 'sheets',
        selectedFilters: <String, Set<String>>{
          'material': <String>{'قطن'},
        },
      ),
    );

    expect(listing.meta.page, 1);
    expect(listing.items, hasLength(1));
    expect(listing.filters.map((group) => group.code), containsAll(<String>['material', 'collection']));
    expect(
      listing.filters.firstWhere((group) => group.code == 'material').values.first.selected,
      isTrue,
    );
  });

  test('product detail resolves by slug as well as id', () async {
    final detail = await repository.fetchProductDetail('serene-sheet-set');

    expect(detail.id, 'sku-100');
    expect(detail.configurableOptions, isNotEmpty);
    expect(detail.variantResolution.combinations, isNotEmpty);
    expect(detail.variantResolution.combinations.first.resolvedSku, 'KL-100-Q-SND');
  });
}
