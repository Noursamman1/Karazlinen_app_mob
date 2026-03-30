import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/product/domain/product_selection.dart';

final FutureProviderFamily<ProductDetailView, String> productDetailProvider =
    FutureProvider.family<ProductDetailView, String>((FutureProviderRef<ProductDetailView> ref, String productId) {
  return ref.watch(catalogRepositoryProvider).fetchProductDetail(productId);
});

class ProductSelectionController extends StateNotifier<ProductSelectionState> {
  ProductSelectionController() : super(const ProductSelectionState());

  void select(String code, String value) {
    state = state.select(code, value);
  }
}

final StateNotifierProviderFamily<ProductSelectionController, ProductSelectionState, String> productSelectionProvider =
    StateNotifierProvider.family<ProductSelectionController, ProductSelectionState, String>(
  (StateNotifierProviderRef<ProductSelectionController, ProductSelectionState> ref, String productId) {
    return ProductSelectionController();
  },
);
