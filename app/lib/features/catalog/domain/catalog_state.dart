class CatalogFilterState {
  const CatalogFilterState({
    this.categoryId,
    this.query = '',
    this.sort = 'featured',
  });

  final String? categoryId;
  final String query;
  final String sort;

  CatalogFilterState copyWith({
    String? categoryId,
    String? query,
    String? sort,
  }) {
    return CatalogFilterState(
      categoryId: categoryId ?? this.categoryId,
      query: query ?? this.query,
      sort: sort ?? this.sort,
    );
  }
}
