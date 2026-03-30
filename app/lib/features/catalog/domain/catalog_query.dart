enum CatalogSortOption {
  featured('featured'),
  priceAsc('price_asc'),
  priceDesc('price_desc');

  const CatalogSortOption(this.apiValue);

  final String apiValue;

  static CatalogSortOption fromApiValue(String value) {
    return CatalogSortOption.values.firstWhere(
      (CatalogSortOption option) => option.apiValue == value,
      orElse: () => CatalogSortOption.featured,
    );
  }
}

const Object _unsetQueryCategoryId = Object();

class CatalogFilterValue {
  const CatalogFilterValue({
    required this.value,
    required this.label,
    required this.count,
    this.selected = false,
  });

  final String value;
  final String label;
  final int count;
  final bool selected;

  CatalogFilterValue copyWith({
    String? value,
    String? label,
    int? count,
    bool? selected,
  }) {
    return CatalogFilterValue(
      value: value ?? this.value,
      label: label ?? this.label,
      count: count ?? this.count,
      selected: selected ?? this.selected,
    );
  }
}

class CatalogFilterGroup {
  const CatalogFilterGroup({
    required this.code,
    required this.label,
    required this.values,
  });

  final String code;
  final String label;
  final List<CatalogFilterValue> values;
}

class CatalogProductQuery {
  const CatalogProductQuery({
    this.categoryId,
    this.searchQuery = '',
    this.sort = CatalogSortOption.featured,
    this.selectedFilters = const <String, Set<String>>{},
    this.page = 1,
    this.pageSize = 24,
  });

  final String? categoryId;
  final String searchQuery;
  final CatalogSortOption sort;
  final Map<String, Set<String>> selectedFilters;
  final int page;
  final int pageSize;

  CatalogProductQuery copyWith({
    Object? categoryId = _unsetQueryCategoryId,
    String? searchQuery,
    CatalogSortOption? sort,
    Map<String, Set<String>>? selectedFilters,
    int? page,
    int? pageSize,
  }) {
    return CatalogProductQuery(
      categoryId: identical(categoryId, _unsetQueryCategoryId) ? this.categoryId : categoryId as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      sort: sort ?? this.sort,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
