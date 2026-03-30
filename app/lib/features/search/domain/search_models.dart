import '../../catalog/domain/catalog_models.dart';

class SearchViewModel {
  const SearchViewModel({
    required this.query,
    required this.results,
    required this.suggestedFilters,
  });

  final String query;
  final List<ProductSummaryModel> results;
  final List<String> suggestedFilters;
}
