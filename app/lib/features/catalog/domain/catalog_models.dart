import '../../../core/network/api_result.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;
}

class ProductSummaryModel {
  const ProductSummaryModel({
    required this.id,
    required this.sku,
    required this.slug,
    required this.name,
    required this.price,
    required this.stockStatus,
  });

  final String id;
  final String sku;
  final String slug;
  final String name;
  final PriceModel price;
  final String stockStatus;
}

class PriceModel {
  const PriceModel({
    required this.amount,
    required this.currencyCode,
    required this.formatted,
  });

  final double amount;
  final String currencyCode;
  final String formatted;
}

class ProductFilterModel {
  const ProductFilterModel({
    required this.label,
    required this.values,
  });

  final String label;
  final List<String> values;
}
