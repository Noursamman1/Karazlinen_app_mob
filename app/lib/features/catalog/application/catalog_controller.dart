import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/catalog/application/catalog_use_cases.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_query.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_result.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_state.dart';

final StateProvider<CatalogFilterState> catalogFilterProvider =
    StateProvider<CatalogFilterState>((Ref ref) => const CatalogFilterState());

final Provider<String?> catalogSelectedCategoryProvider = Provider<String?>((Ref ref) {
  return ref.watch(catalogFilterProvider).categoryId;
});

final Provider<String> catalogSortProvider = Provider<String>((Ref ref) {
  return ref.watch(catalogFilterProvider).sort.apiValue;
});

final Provider<int> catalogActiveFilterCountProvider = Provider<int>((Ref ref) {
  final CatalogFilterState filters = ref.watch(catalogFilterProvider);
  return countSelectedCatalogFilters(filters);
});

final catalogCategoriesProvider = FutureProvider<List<CategoryView>>((Ref ref) {
  return ref.watch(loadCatalogCategoriesUseCaseProvider).call();
});

final catalogListingProvider = FutureProvider<CatalogProductListing>((Ref ref) {
  final CatalogFilterState filters = ref.watch(catalogFilterProvider);
  return ref.watch(loadCatalogListingUseCaseProvider).call(
        CatalogProductQuery(
          categoryId: filters.categoryId,
          searchQuery: filters.query,
          sort: filters.sort,
          selectedFilters: filters.selectedFilters,
        ),
      );
});

final catalogProductsProvider = FutureProvider<List<ProductSummaryView>>((Ref ref) async {
  return (await ref.watch(catalogListingProvider.future)).items;
});

void updateCatalogCategory(WidgetRef ref, String? categoryId) {
  ref.read(catalogFilterProvider.notifier).state = ref.read(catalogFilterProvider).copyWith(
        categoryId: categoryId,
      );
}

void updateCatalogSort(WidgetRef ref, String sort) {
  ref.read(catalogFilterProvider.notifier).state = ref.read(catalogFilterProvider).copyWith(
        sort: CatalogSortOption.fromApiValue(sort),
      );
}

void toggleCatalogFilter(WidgetRef ref, String code, String value) {
  ref.read(catalogFilterProvider.notifier).state = ref.read(catalogFilterProvider).toggleFilter(code, value);
}

void clearCatalogFilters(WidgetRef ref) {
  ref.read(catalogFilterProvider.notifier).state = ref.read(catalogFilterProvider).copyWith(
        selectedFilters: const <String, Set<String>>{},
      );
}

List<CatalogFilterGroup> readAvailableCatalogFilters(
  WidgetRef _,
  AsyncValue<CatalogProductListing> listing,
) {
  return listing.maybeWhen(
    data: (CatalogProductListing data) => data.filters,
    orElse: () => const <CatalogFilterGroup>[],
  );
}

int countSelectedCatalogFilters(CatalogFilterState filters) {
  return filters.selectedFilters.values.fold<int>(
    0,
    (int total, Set<String> values) => total + values.length,
  );
}
