import 'catalog_query.dart';

const Object _unsetCategoryId = Object();

class CatalogFilterState {
  const CatalogFilterState({
    this.categoryId,
    this.query = '',
    this.sort = CatalogSortOption.featured,
    this.selectedFilters = const <String, Set<String>>{},
  });

  final String? categoryId;
  final String query;
  final CatalogSortOption sort;
  final Map<String, Set<String>> selectedFilters;

  CatalogFilterState copyWith({
    Object? categoryId = _unsetCategoryId,
    String? query,
    CatalogSortOption? sort,
    Map<String, Set<String>>? selectedFilters,
  }) {
    return CatalogFilterState(
      categoryId: identical(categoryId, _unsetCategoryId) ? this.categoryId : categoryId as String?,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      selectedFilters: selectedFilters ?? this.selectedFilters,
    );
  }

  CatalogFilterState toggleFilter(String code, String value) {
    final Set<String> currentValues = Set<String>.from(selectedFilters[code] ?? const <String>{});
    if (currentValues.contains(value)) {
      currentValues.remove(value);
    } else {
      currentValues.add(value);
    }

    final Map<String, Set<String>> nextFilters = <String, Set<String>>{
      for (final MapEntry<String, Set<String>> entry in selectedFilters.entries)
        entry.key: Set<String>.from(entry.value),
    };

    if (currentValues.isEmpty) {
      nextFilters.remove(code);
    } else {
      nextFilters[code] = currentValues;
    }

    return copyWith(selectedFilters: nextFilters);
  }
}
