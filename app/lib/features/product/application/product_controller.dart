import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/catalog/application/catalog_use_cases.dart';
import 'package:karaz_linen_app/features/product/domain/product_selection.dart';

final productDetailsProvider = FutureProvider.family<ProductDetailView, String>((Ref ref, String productId) {
  return ref.watch(loadProductDetailUseCaseProvider).call(productId);
});

class ProductSelectionController extends StateNotifier<ProductSelectionState> {
  ProductSelectionController() : super(const ProductSelectionState());

  void select(String optionCode, String value) {
    state = state.select(optionCode, value);
  }

  void clear(String optionCode) {
    state = state.clear(optionCode);
  }

  void selectOrClear({
    required String optionCode,
    required String value,
    required bool selected,
  }) {
    if (selected) {
      state = state.select(optionCode, value);
      return;
    }
    state = state.clear(optionCode);
  }
}

final productSelectionProvider =
    StateNotifierProvider.family<ProductSelectionController, ProductSelectionState, String>(
  (Ref ref, String productId) => ProductSelectionController(),
);

final productSelectionSummaryProvider = Provider.family<AsyncValue<ProductSelectionSummary>, String>(
  (Ref ref, String productId) {
    final AsyncValue<ProductDetailView> detail = ref.watch(productDetailsProvider(productId));
    final ProductSelectionState selection = ref.watch(productSelectionProvider(productId));
    return detail.whenData(
      (ProductDetailView value) => ProductSelectionSummary.fromProduct(value, selection),
    );
  },
);
