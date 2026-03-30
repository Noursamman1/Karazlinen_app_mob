import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/commerce_models.dart';

final searchQueryProvider = StateProvider<String>((Ref ref) => '');

final searchResultsProvider = FutureProvider<List<ProductSummaryView>>((Ref ref) {
  final String query = ref.watch(searchQueryProvider);
  return ref.watch(catalogRepositoryProvider).fetchProducts(query: query);
});
