import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';

final productDetailsProvider = FutureProvider.family<ProductDetailView, String>((Ref ref, String productId) {
  return ref.watch(catalogRepositoryProvider).fetchProductDetail(productId);
});

class ProductSelectionController extends StateNotifier<Map<String, String>> {
  ProductSelectionController() : super(const <String, String>{});

  void select(String optionCode, String value) {
    state = <String, String>{
      ...state,
      optionCode: value,
    };
  }
}

final productSelectionProvider = StateNotifierProvider.family<ProductSelectionController, Map<String, String>, String>(
  (Ref ref, String productId) => ProductSelectionController(),
);
