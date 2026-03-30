import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/features/search/application/search_controller.dart';

void main() {
  test('search query starts empty', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(searchQueryProvider), isEmpty);
  });

  test('search filter count updates and clears correctly', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(searchFilterProvider.notifier).state = container.read(searchFilterProvider).toggleFilter('material', 'قطن');

    expect(container.read(searchActiveFilterCountProvider), 1);

    container.read(searchFilterProvider.notifier).state = container.read(searchFilterProvider).copyWith(
          selectedFilters: const <String, Set<String>>{},
        );

    expect(container.read(searchActiveFilterCountProvider), 0);
  });
}
