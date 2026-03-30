import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_query.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_result.dart';

abstract class CatalogRepository {
  Future<List<CategoryView>> fetchCategories();
  Future<CatalogProductListing> fetchProductListing(CatalogProductQuery query);
  Future<ProductDetailView> fetchProductDetail(String productIdOrSlug);
}

class DemoCatalogRepository implements CatalogRepository {
  const DemoCatalogRepository();

  @override
  Future<List<CategoryView>> fetchCategories() async {
    final Map<String, dynamic> response = <String, dynamic>{
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'bedroom',
          'name': 'غرفة النوم',
          'slug': 'bedroom',
          'children': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'sheets', 'name': 'أغطية السرير', 'slug': 'sheets'},
            <String, dynamic>{'id': 'pillows', 'name': 'الوسائد', 'slug': 'pillows'},
          ],
        },
        <String, dynamic>{'id': 'bath', 'name': 'الحمام', 'slug': 'bath'},
        <String, dynamic>{'id': 'living', 'name': 'الاستقبال', 'slug': 'living'},
      ],
    };

    final List<dynamic> items = response['items'] as List<dynamic>? ?? const <dynamic>[];
    return items.map((dynamic item) => _mapCategory(item as Map<String, dynamic>)).toList(growable: false);
  }

  @override
  Future<CatalogProductListing> fetchProductListing(CatalogProductQuery query) async {
    final List<_DemoProductDocument> scopedCatalog = _catalog
        .where((_DemoProductDocument item) => query.categoryId == null || item.categoryId == query.categoryId)
        .toList(growable: false);

    final List<_DemoProductDocument> filteredCatalog = scopedCatalog.where((_DemoProductDocument item) {
      final String normalizedQuery = query.searchQuery.trim().toLowerCase();
      if (normalizedQuery.isNotEmpty) {
        final bool matchesQuery = item.name.toLowerCase().contains(normalizedQuery) ||
            (item.subtitle?.toLowerCase().contains(normalizedQuery) ?? false);
        if (!matchesQuery) {
          return false;
        }
      }

      for (final MapEntry<String, Set<String>> entry in query.selectedFilters.entries) {
        final String? value = item.attributes[entry.key];
        if (value == null || !entry.value.contains(value)) {
          return false;
        }
      }

      return true;
    }).toList(growable: false);

    final List<_DemoProductDocument> sortedCatalog = _sortProducts(filteredCatalog, query.sort);
    final int totalItems = sortedCatalog.length;
    final int totalPages = totalItems == 0 ? 1 : (totalItems / query.pageSize).ceil();
    final int startIndex = (query.page - 1) * query.pageSize;
    final int safeStart = startIndex.clamp(0, sortedCatalog.length) as int;
    final int safeEnd = (safeStart + query.pageSize).clamp(0, sortedCatalog.length) as int;
    final List<_DemoProductDocument> pageItems = sortedCatalog.sublist(safeStart, safeEnd);

    final Map<String, dynamic> response = <String, dynamic>{
      'items': pageItems.map(_productSummaryPayload).toList(growable: false),
      'meta': <String, dynamic>{
        'page': query.page,
        'pageSize': query.pageSize,
        'totalItems': totalItems,
        'totalPages': totalPages,
      },
      'aggregations': _buildFilterGroups(
        source: scopedCatalog,
        selectedFilters: query.selectedFilters,
      ).map(_facetGroupPayload).toList(growable: false),
    };

    return CatalogProductListing(
      items: (response['items'] as List<dynamic>)
          .map((dynamic item) => _mapProductSummary(item as Map<String, dynamic>))
          .toList(growable: false),
      meta: _mapPageMeta(response['meta'] as Map<String, dynamic>),
      filters: (response['aggregations'] as List<dynamic>)
          .map((dynamic item) => _mapFilterGroup(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  @override
  Future<ProductDetailView> fetchProductDetail(String productIdOrSlug) async {
    final _DemoProductDocument document = _catalog.firstWhere(
      (_DemoProductDocument item) => item.id == productIdOrSlug || item.slug == productIdOrSlug,
    );

    final Map<String, dynamic> response = <String, dynamic>{
      ..._productSummaryPayload(document),
      'gallery': document.galleryUrls.map((String url) => <String, dynamic>{'url': url}).toList(growable: false),
      'description': document.description,
      'configurableOptions': document.configurableOptions.map((ConfigurableOptionView option) {
        return <String, dynamic>{
          'code': option.code,
          'label': option.label,
          'values': option.values.map((ConfigurableValueView value) {
            return <String, dynamic>{
              'value': value.value,
              'label': value.label,
              'available': value.available,
            };
          }).toList(growable: false),
        };
      }).toList(growable: false),
      'variantResolution': <String, dynamic>{
        'mode': document.variantCombinations.isEmpty ? 'base_product' : 'resolved_combinations',
        'unresolvedReason': document.variantCombinations.isEmpty ? 'No variant combinations are defined.' : null,
        'combinations': document.variantCombinations.map((_DemoVariantCombinationDocument combination) {
          return <String, dynamic>{
            'selection': combination.selection,
            'resolvedSku': combination.resolvedSku,
            'availability': combination.availability,
            'image': combination.imageUrl == null ? null : <String, dynamic>{'url': combination.imageUrl},
            'price': _moneyPayload(combination.price),
          };
        }).toList(growable: false),
      },
    };

    return _mapProductDetail(response);
  }

  CategoryView _mapCategory(Map<String, dynamic> payload) {
    return CategoryView(
      id: payload['id'] as String,
      name: payload['name'] as String,
      slug: payload['slug'] as String,
      image: payload['image'] == null ? null : _mapImage(payload['image'] as Map<String, dynamic>),
      children: (payload['children'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic child) => _mapCategory(child as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  ProductSummaryView _mapProductSummary(Map<String, dynamic> payload) {
    return ProductSummaryView(
      id: payload['id'] as String,
      sku: payload['sku'] as String,
      slug: payload['slug'] as String,
      name: payload['name'] as String,
      subtitle: payload['subtitle'] as String?,
      thumbnail: payload['thumbnail'] == null ? null : _mapImage(payload['thumbnail'] as Map<String, dynamic>),
      price: _mapMoney(payload['price'] as Map<String, dynamic>),
      compareAtPrice:
          payload['compareAtPrice'] == null ? null : _mapMoney(payload['compareAtPrice'] as Map<String, dynamic>),
      stockStatus: payload['stockStatus'] as String,
    );
  }

  ProductDetailView _mapProductDetail(Map<String, dynamic> payload) {
    return ProductDetailView(
      id: payload['id'] as String,
      sku: payload['sku'] as String,
      slug: payload['slug'] as String,
      name: payload['name'] as String,
      subtitle: payload['subtitle'] as String?,
      thumbnail: payload['thumbnail'] == null ? null : _mapImage(payload['thumbnail'] as Map<String, dynamic>),
      price: _mapMoney(payload['price'] as Map<String, dynamic>),
      compareAtPrice:
          payload['compareAtPrice'] == null ? null : _mapMoney(payload['compareAtPrice'] as Map<String, dynamic>),
      stockStatus: payload['stockStatus'] as String,
      gallery: (payload['gallery'] as List<dynamic>)
          .map((dynamic image) => _mapImage(image as Map<String, dynamic>))
          .toList(growable: false),
      description: payload['description'] as String?,
      configurableOptions: (payload['configurableOptions'] as List<dynamic>)
          .map((dynamic option) => _mapConfigurableOption(option as Map<String, dynamic>))
          .toList(growable: false),
      variantResolution: _mapVariantResolution(payload['variantResolution'] as Map<String, dynamic>),
    );
  }

  ConfigurableOptionView _mapConfigurableOption(Map<String, dynamic> payload) {
    return ConfigurableOptionView(
      code: payload['code'] as String,
      label: payload['label'] as String,
      values: (payload['values'] as List<dynamic>).map((dynamic value) {
        final Map<String, dynamic> data = value as Map<String, dynamic>;
        return ConfigurableValueView(
          value: data['value'] as String,
          label: data['label'] as String,
          available: data['available'] as bool? ?? false,
        );
      }).toList(growable: false),
    );
  }

  VariantResolutionView _mapVariantResolution(Map<String, dynamic> payload) {
    return VariantResolutionView(
      mode: payload['mode'] as String? ?? 'base_product',
      unresolvedReason: payload['unresolvedReason'] as String?,
      combinations: (payload['combinations'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic item) => _mapResolvedVariantCombination(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  ResolvedVariantCombinationView _mapResolvedVariantCombination(Map<String, dynamic> payload) {
    return ResolvedVariantCombinationView(
      selection: Map<String, String>.from(payload['selection'] as Map<String, dynamic>? ?? const <String, dynamic>{}),
      resolvedSku: payload['resolvedSku'] as String,
      availability: payload['availability'] as String,
      image: payload['image'] == null ? null : _mapImage(payload['image'] as Map<String, dynamic>),
      price: _mapMoney(payload['price'] as Map<String, dynamic>),
    );
  }

  CatalogPageMeta _mapPageMeta(Map<String, dynamic> payload) {
    return CatalogPageMeta(
      page: payload['page'] as int? ?? 1,
      pageSize: payload['pageSize'] as int? ?? 24,
      totalItems: payload['totalItems'] as int? ?? 0,
      totalPages: payload['totalPages'] as int? ?? 1,
    );
  }

  CatalogFilterGroup _mapFilterGroup(Map<String, dynamic> payload) {
    return CatalogFilterGroup(
      code: payload['code'] as String,
      label: payload['label'] as String,
      values: (payload['values'] as List<dynamic>)
          .map((dynamic item) => _mapFilterValue(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  CatalogFilterValue _mapFilterValue(Map<String, dynamic> payload) {
    return CatalogFilterValue(
      value: payload['value'] as String,
      label: payload['label'] as String,
      count: payload['count'] as int? ?? 0,
      selected: payload['selected'] as bool? ?? false,
    );
  }

  MoneyView _mapMoney(Map<String, dynamic> payload) {
    return MoneyView(
      amount: (payload['amount'] as num).toDouble(),
      currencyCode: payload['currencyCode'] as String,
      formatted: payload['formatted'] as String,
    );
  }

  ImageView _mapImage(Map<String, dynamic> payload) {
    return ImageView(
      url: payload['url'] as String,
      alt: payload['alt'] as String?,
    );
  }

  Map<String, dynamic> _productSummaryPayload(_DemoProductDocument product) {
    return <String, dynamic>{
      'id': product.id,
      'sku': product.sku,
      'slug': product.slug,
      'name': product.name,
      'subtitle': product.subtitle,
      'thumbnail': <String, dynamic>{'url': product.thumbnailUrl},
      'price': _moneyPayload(product.price),
      'compareAtPrice': product.compareAtPrice == null ? null : _moneyPayload(product.compareAtPrice!),
      'stockStatus': product.stockStatus,
    };
  }

  Map<String, dynamic> _moneyPayload(double amount) {
    return <String, dynamic>{
      'amount': amount,
      'currencyCode': 'SAR',
      'formatted': '${amount.toInt()} ر.س',
    };
  }

  Map<String, dynamic> _facetGroupPayload(CatalogFilterGroup group) {
    return <String, dynamic>{
      'code': group.code,
      'label': group.label,
      'values': group.values
          .map(
            (CatalogFilterValue value) => <String, dynamic>{
              'value': value.value,
              'label': value.label,
              'count': value.count,
              'selected': value.selected,
            },
          )
          .toList(growable: false),
    };
  }

  List<_DemoProductDocument> _sortProducts(List<_DemoProductDocument> items, CatalogSortOption sort) {
    final List<_DemoProductDocument> sorted = List<_DemoProductDocument>.from(items);
    switch (sort) {
      case CatalogSortOption.featured:
        sorted.sort(
          (_DemoProductDocument left, _DemoProductDocument right) => left.featureRank.compareTo(right.featureRank),
        );
      case CatalogSortOption.priceAsc:
        sorted.sort((_DemoProductDocument left, _DemoProductDocument right) => left.price.compareTo(right.price));
      case CatalogSortOption.priceDesc:
        sorted.sort((_DemoProductDocument left, _DemoProductDocument right) => right.price.compareTo(left.price));
    }
    return sorted;
  }

  List<CatalogFilterGroup> _buildFilterGroups({
    required List<_DemoProductDocument> source,
    required Map<String, Set<String>> selectedFilters,
  }) {
    final Map<String, String> labels = const <String, String>{
      'material': 'الخامة',
      'collection': 'المجموعة',
    };

    return labels.entries.map((MapEntry<String, String> entry) {
      final Map<String, int> counts = <String, int>{};
      for (final _DemoProductDocument product in source) {
        final String? value = product.attributes[entry.key];
        if (value == null) {
          continue;
        }
        counts.update(value, (int current) => current + 1, ifAbsent: () => 1);
      }

      final List<CatalogFilterValue> values = counts.entries.map((MapEntry<String, int> countEntry) {
        return CatalogFilterValue(
          value: countEntry.key,
          label: countEntry.key,
          count: countEntry.value,
          selected: selectedFilters[entry.key]?.contains(countEntry.key) ?? false,
        );
      }).toList(growable: false);

      return CatalogFilterGroup(
        code: entry.key,
        label: entry.value,
        values: values,
      );
    }).where((CatalogFilterGroup group) => group.values.isNotEmpty).toList(growable: false);
  }

  static const List<_DemoProductDocument> _catalog = <_DemoProductDocument>[
    _DemoProductDocument(
      id: 'sku-100',
      sku: 'KL-100',
      slug: 'serene-sheet-set',
      categoryId: 'sheets',
      name: 'طقم سرير سيرين',
      subtitle: 'قطن ناعم بلمسة فندقية',
      thumbnailUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=900',
      galleryUrls: <String>[
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1200',
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1201',
      ],
      price: 399,
      compareAtPrice: 499,
      stockStatus: 'in_stock',
      featureRank: 1,
      description: 'نسيج هادئ بملمس ناعم وتشطيب أنيق مناسب للأجواء الهادئة والفاخرة.',
      attributes: <String, String>{'material': 'قطن', 'collection': 'Serene'},
      configurableOptions: <ConfigurableOptionView>[
        ConfigurableOptionView(
          code: 'size',
          label: 'المقاس',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'queen', label: 'كوين', available: true),
            ConfigurableValueView(value: 'king', label: 'كينغ', available: true),
          ],
        ),
        ConfigurableOptionView(
          code: 'color',
          label: 'اللون',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'sand', label: 'رملي', available: true),
            ConfigurableValueView(value: 'ivory', label: 'عاجي', available: true),
          ],
        ),
      ],
      variantCombinations: <_DemoVariantCombinationDocument>[
        _DemoVariantCombinationDocument(
          selection: <String, String>{'size': 'queen', 'color': 'sand'},
          resolvedSku: 'KL-100-Q-SND',
          availability: 'in_stock',
          imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1202',
          price: 399,
        ),
        _DemoVariantCombinationDocument(
          selection: <String, String>{'size': 'queen', 'color': 'ivory'},
          resolvedSku: 'KL-100-Q-IVY',
          availability: 'low_stock',
          imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1203',
          price: 419,
        ),
        _DemoVariantCombinationDocument(
          selection: <String, String>{'size': 'king', 'color': 'sand'},
          resolvedSku: 'KL-100-K-SND',
          availability: 'in_stock',
          imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1204',
          price: 449,
        ),
        _DemoVariantCombinationDocument(
          selection: <String, String>{'size': 'king', 'color': 'ivory'},
          resolvedSku: 'KL-100-K-IVY',
          availability: 'out_of_stock',
          imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1205',
          price: 459,
        ),
      ],
    ),
    _DemoProductDocument(
      id: 'sku-101',
      sku: 'KL-101',
      slug: 'calm-duvet-cover',
      categoryId: 'bedroom',
      name: 'غطاء لحاف كالم',
      subtitle: 'نقش هادئ وتشطيب فاخر',
      thumbnailUrl: 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=900',
      galleryUrls: <String>[
        'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=1200',
      ],
      price: 520,
      stockStatus: 'low_stock',
      featureRank: 2,
      description: 'تصميم هادئ بطبقات ناعمة ينسجم مع غرف النوم الراقية.',
      attributes: <String, String>{'material': 'ساتان', 'collection': 'Calm'},
      configurableOptions: <ConfigurableOptionView>[
        ConfigurableOptionView(
          code: 'size',
          label: 'المقاس',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'queen', label: 'كوين', available: true),
            ConfigurableValueView(value: 'super-king', label: 'سوبر كينغ', available: true),
          ],
        ),
      ],
      variantCombinations: <_DemoVariantCombinationDocument>[
        _DemoVariantCombinationDocument(
          selection: <String, String>{'size': 'queen'},
          resolvedSku: 'KL-101-Q',
          availability: 'low_stock',
          imageUrl: 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=1201',
          price: 520,
        ),
        _DemoVariantCombinationDocument(
          selection: <String, String>{'size': 'super-king'},
          resolvedSku: 'KL-101-SK',
          availability: 'in_stock',
          imageUrl: 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=1202',
          price: 560,
        ),
      ],
    ),
    _DemoProductDocument(
      id: 'sku-102',
      sku: 'KL-102',
      slug: 'bath-towel-signature',
      categoryId: 'bath',
      name: 'منشفة سيغنتشر',
      subtitle: 'سماكة مريحة وامتصاص عالٍ',
      thumbnailUrl: 'https://images.unsplash.com/photo-1631049035182-249067d7618e?w=900',
      galleryUrls: <String>[
        'https://images.unsplash.com/photo-1631049035182-249067d7618e?w=1200',
      ],
      price: 129,
      stockStatus: 'in_stock',
      featureRank: 3,
      description: 'ملمس كثيف وامتصاص عملي للاستخدام اليومي مع طابع فاخر.',
      attributes: <String, String>{'material': 'قطن', 'collection': 'Signature'},
      configurableOptions: <ConfigurableOptionView>[
        ConfigurableOptionView(
          code: 'color',
          label: 'اللون',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'white', label: 'أبيض', available: true),
            ConfigurableValueView(value: 'stone', label: 'حجري', available: true),
          ],
        ),
      ],
      variantCombinations: <_DemoVariantCombinationDocument>[
        _DemoVariantCombinationDocument(
          selection: <String, String>{'color': 'white'},
          resolvedSku: 'KL-102-WHT',
          availability: 'in_stock',
          imageUrl: 'https://images.unsplash.com/photo-1631049035182-249067d7618e?w=1201',
          price: 129,
        ),
        _DemoVariantCombinationDocument(
          selection: <String, String>{'color': 'stone'},
          resolvedSku: 'KL-102-STN',
          availability: 'in_stock',
          imageUrl: 'https://images.unsplash.com/photo-1631049035182-249067d7618e?w=1202',
          price: 139,
        ),
      ],
    ),
  ];
}

class _DemoProductDocument {
  const _DemoProductDocument({
    required this.id,
    required this.sku,
    required this.slug,
    required this.categoryId,
    required this.name,
    required this.thumbnailUrl,
    required this.galleryUrls,
    required this.price,
    required this.stockStatus,
    required this.featureRank,
    required this.description,
    required this.attributes,
    required this.configurableOptions,
    required this.variantCombinations,
    this.subtitle,
    this.compareAtPrice,
  });

  final String id;
  final String sku;
  final String slug;
  final String categoryId;
  final String name;
  final String? subtitle;
  final String thumbnailUrl;
  final List<String> galleryUrls;
  final double price;
  final double? compareAtPrice;
  final String stockStatus;
  final int featureRank;
  final String description;
  final Map<String, String> attributes;
  final List<ConfigurableOptionView> configurableOptions;
  final List<_DemoVariantCombinationDocument> variantCombinations;
}

class _DemoVariantCombinationDocument {
  const _DemoVariantCombinationDocument({
    required this.selection,
    required this.resolvedSku,
    required this.availability,
    required this.price,
    this.imageUrl,
  });

  final Map<String, String> selection;
  final String resolvedSku;
  final String availability;
  final String? imageUrl;
  final double price;
}
