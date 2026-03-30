import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/features/catalog/domain/catalog_state.dart';

void main() {
  test('catalog filters update query and sort independently', () {
    const CatalogFilterState filters = CatalogFilterState();
    final CatalogFilterState next = filters.copyWith(query: 'linen', sort: 'price_desc');
    expect(next.query, 'linen');
    expect(next.sort, 'price_desc');
  });
}
