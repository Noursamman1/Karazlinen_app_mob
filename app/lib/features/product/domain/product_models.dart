import '../../catalog/domain/catalog_models.dart';

class ProductDetailViewModel {
  const ProductDetailViewModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.stockStatus,
    required this.options,
  });

  final String id;
  final String name;
  final PriceModel price;
  final String description;
  final String stockStatus;
  final List<ConfigurableOptionModel> options;
}

class ConfigurableOptionModel {
  const ConfigurableOptionModel({
    required this.code,
    required this.label,
    required this.values,
  });

  final String code;
  final String label;
  final List<ConfigurableValueModel> values;
}

class ConfigurableValueModel {
  const ConfigurableValueModel({
    required this.value,
    required this.label,
    required this.available,
  });

  final String value;
  final String label;
  final bool available;
}
