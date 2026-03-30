import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/repositories/catalog_repository.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_query.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_result.dart';

class LoadCatalogCategoriesUseCase {
  const LoadCatalogCategoriesUseCase(this._repository);

  final CatalogRepository _repository;

  Future<List<CategoryView>> call() {
    return _repository.fetchCategories();
  }
}

class LoadCatalogListingUseCase {
  const LoadCatalogListingUseCase(this._repository);

  final CatalogRepository _repository;

  Future<CatalogProductListing> call(CatalogProductQuery query) {
    return _repository.fetchProductListing(query);
  }
}

class LoadProductDetailUseCase {
  const LoadProductDetailUseCase(this._repository);

  final CatalogRepository _repository;

  Future<ProductDetailView> call(String productIdOrSlug) {
    return _repository.fetchProductDetail(productIdOrSlug);
  }
}

final Provider<LoadCatalogCategoriesUseCase> loadCatalogCategoriesUseCaseProvider =
    Provider<LoadCatalogCategoriesUseCase>((Ref ref) {
  return LoadCatalogCategoriesUseCase(ref.watch(catalogRepositoryProvider));
});

final Provider<LoadCatalogListingUseCase> loadCatalogListingUseCaseProvider = Provider<LoadCatalogListingUseCase>((Ref ref) {
  return LoadCatalogListingUseCase(ref.watch(catalogRepositoryProvider));
});

final Provider<LoadProductDetailUseCase> loadProductDetailUseCaseProvider = Provider<LoadProductDetailUseCase>((Ref ref) {
  return LoadProductDetailUseCase(ref.watch(catalogRepositoryProvider));
});
