class MoneyView {
  const MoneyView({
    required this.amount,
    required this.currencyCode,
    required this.formatted,
  });

  final double amount;
  final String currencyCode;
  final String formatted;
}

class ImageView {
  const ImageView({
    required this.url,
    this.alt,
  });

  final String url;
  final String? alt;
}

class CategoryView {
  const CategoryView({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.children = const <CategoryView>[],
  });

  final String id;
  final String name;
  final String slug;
  final ImageView? image;
  final List<CategoryView> children;
}

class ProductSummaryView {
  const ProductSummaryView({
    required this.id,
    required this.sku,
    required this.slug,
    required this.name,
    required this.price,
    required this.stockStatus,
    this.subtitle,
    this.thumbnail,
    this.compareAtPrice,
  });

  final String id;
  final String sku;
  final String slug;
  final String name;
  final String? subtitle;
  final ImageView? thumbnail;
  final MoneyView price;
  final MoneyView? compareAtPrice;
  final String stockStatus;
}

class ConfigurableValueView {
  const ConfigurableValueView({
    required this.value,
    required this.label,
    required this.available,
  });

  final String value;
  final String label;
  final bool available;
}

class ConfigurableOptionView {
  const ConfigurableOptionView({
    required this.code,
    required this.label,
    required this.values,
  });

  final String code;
  final String label;
  final List<ConfigurableValueView> values;
}

class ProductDetailView extends ProductSummaryView {
  const ProductDetailView({
    required super.id,
    required super.sku,
    required super.slug,
    required super.name,
    required super.price,
    required super.stockStatus,
    required this.gallery,
    required this.configurableOptions,
    super.subtitle,
    super.thumbnail,
    super.compareAtPrice,
    this.description,
  });

  final List<ImageView> gallery;
  final String? description;
  final List<ConfigurableOptionView> configurableOptions;
}
