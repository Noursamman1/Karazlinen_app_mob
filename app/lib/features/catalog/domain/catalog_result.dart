import 'package:karaz_linen_app/core/models/commerce_models.dart';

import 'catalog_query.dart';

class CatalogPageMeta {
  const CatalogPageMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
}

class CatalogProductListing {
  const CatalogProductListing({
    required this.items,
    required this.meta,
    this.filters = const <CatalogFilterGroup>[],
  });

  final List<ProductSummaryView> items;
  final CatalogPageMeta meta;
  final List<CatalogFilterGroup> filters;
}
