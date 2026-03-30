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

class ResolvedVariantCombinationView {
  const ResolvedVariantCombinationView({
    required this.selection,
    required this.resolvedSku,
    required this.availability,
    required this.price,
    this.image,
  });

  final Map<String, String> selection;
  final String resolvedSku;
  final String availability;
  final ImageView? image;
  final MoneyView price;

  bool matchesSelection(Map<String, String> selectedValues) {
    if (selection.length != selectedValues.length) {
      return false;
    }

    for (final MapEntry<String, String> entry in selection.entries) {
      if (selectedValues[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}

class VariantResolutionView {
  const VariantResolutionView({
    required this.mode,
    this.combinations = const <ResolvedVariantCombinationView>[],
    this.unresolvedReason,
  });

  final String mode;
  final List<ResolvedVariantCombinationView> combinations;
  final String? unresolvedReason;

  bool get hasResolvedCombinations => mode == 'resolved_combinations' && combinations.isNotEmpty;
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
    required this.variantResolution,
    super.subtitle,
    super.thumbnail,
    super.compareAtPrice,
    this.description,
  });

  final List<ImageView> gallery;
  final String? description;
  final List<ConfigurableOptionView> configurableOptions;
  final VariantResolutionView variantResolution;
}
