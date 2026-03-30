import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_state.dart';

final StateProvider<CatalogFilterState> catalogFilterProvider =
    StateProvider<CatalogFilterState>((StateProviderRef<CatalogFilterState> ref) => const CatalogFilterState());

final FutureProvider<List<CategoryView>> categoriesProvider = FutureProvider<List<CategoryView>>((FutureProviderRef<List<CategoryView>> ref) {
  return ref.watch(catalogRepositoryProvider).fetchCategories();
});

final FutureProvider<List<ProductSummaryView>> productListProvider =
    FutureProvider<List<ProductSummaryView>>((FutureProviderRef<List<ProductSummaryView>> ref) {
  final CatalogFilterState filters = ref.watch(catalogFilterProvider);
  return ref.watch(catalogRepositoryProvider).fetchProducts(
        categoryId: filters.categoryId,
        query: filters.query,
        sort: filters.sort,
      );
});
