import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karaz_linen_app/features/catalog/application/catalog_controller.dart';

void main() {
  test('default catalog sort is featured', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(catalogSortProvider), 'featured');
  });
}
