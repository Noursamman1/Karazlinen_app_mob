import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karaz_linen_app/features/search/application/search_controller.dart';

void main() {
  test('search query starts empty', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(searchQueryProvider), isEmpty);
  });
}
