import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/catalog/application/catalog_controller.dart';
import 'package:karaz_linen_app/features/catalog/application/catalog_use_cases.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_query.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_result.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_state.dart';

final StateProvider<CatalogFilterState> searchFilterProvider =
    StateProvider<CatalogFilterState>((Ref ref) => const CatalogFilterState());

final Provider<String> searchQueryProvider = Provider<String>((Ref ref) {
  return ref.watch(searchFilterProvider).query;
});

final Provider<String> searchSortProvider = Provider<String>((Ref ref) {
  return ref.watch(searchFilterProvider).sort.apiValue;
});

final Provider<int> searchActiveFilterCountProvider = Provider<int>((Ref ref) {
  return countSelectedCatalogFilters(ref.watch(searchFilterProvider));
});

final searchListingProvider = FutureProvider<CatalogProductListing>((Ref ref) {
  final CatalogFilterState filters = ref.watch(searchFilterProvider);
  return ref.watch(loadCatalogListingUseCaseProvider).call(
        CatalogProductQuery(
          searchQuery: filters.query,
          sort: filters.sort,
          selectedFilters: filters.selectedFilters,
        ),
      );
});

final searchResultsProvider = FutureProvider<List<ProductSummaryView>>((Ref ref) async {
  return (await ref.watch(searchListingProvider.future)).items;
});

void updateSearchQuery(WidgetRef ref, String query) {
  ref.read(searchFilterProvider.notifier).state = ref.read(searchFilterProvider).copyWith(
        query: query,
      );
}

void updateSearchSort(WidgetRef ref, String sort) {
  ref.read(searchFilterProvider.notifier).state = ref.read(searchFilterProvider).copyWith(
        sort: CatalogSortOption.fromApiValue(sort),
      );
}

void toggleSearchFilter(WidgetRef ref, String code, String value) {
  ref.read(searchFilterProvider.notifier).state = ref.read(searchFilterProvider).toggleFilter(code, value);
}

void clearSearchFilters(WidgetRef ref) {
  ref.read(searchFilterProvider.notifier).state = ref.read(searchFilterProvider).copyWith(
        selectedFilters: const <String, Set<String>>{},
      );
}

void resetSearchState(WidgetRef ref) {
  ref.read(searchFilterProvider.notifier).state = const CatalogFilterState();
}

List<CatalogFilterGroup> readAvailableSearchFilters(
  WidgetRef _,
  AsyncValue<CatalogProductListing> listing,
) {
  return listing.maybeWhen(
    data: (CatalogProductListing data) => data.filters,
    orElse: () => const <CatalogFilterGroup>[],
  );
}
