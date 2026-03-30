import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';

final catalogSelectedCategoryProvider = StateProvider<String?>((Ref ref) => null);
final catalogSortProvider = StateProvider<String>((Ref ref) => 'featured');

final catalogCategoriesProvider = FutureProvider<List<CategoryView>>((Ref ref) {
  return ref.watch(catalogRepositoryProvider).fetchCategories();
});

final catalogProductsProvider = FutureProvider<List<ProductSummaryView>>((Ref ref) {
  final String? categoryId = ref.watch(catalogSelectedCategoryProvider);
  final String sort = ref.watch(catalogSortProvider);
  return ref.watch(catalogRepositoryProvider).fetchProducts(
        categoryId: categoryId,
        sort: sort,
      );
});
