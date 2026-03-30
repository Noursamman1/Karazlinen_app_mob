import 'package:karaz_linen_app/core/models/commerce_models.dart';

abstract class CatalogRepository {
  Future<List<CategoryView>> fetchCategories();
  Future<List<ProductSummaryView>> fetchProducts({
    String? categoryId,
    String? query,
    String sort = 'featured',
  });
  Future<ProductDetailView> fetchProductDetail(String productId);
}

class DemoCatalogRepository implements CatalogRepository {
  const DemoCatalogRepository();

  @override
  Future<List<CategoryView>> fetchCategories() async {
    return const <CategoryView>[
      CategoryView(
        id: 'bedroom',
        name: 'غرفة النوم',
        slug: 'bedroom',
        children: <CategoryView>[
          CategoryView(id: 'sheets', name: 'أغطية السرير', slug: 'sheets'),
          CategoryView(id: 'pillows', name: 'الوسائد', slug: 'pillows'),
        ],
      ),
      CategoryView(id: 'bath', name: 'الحمام', slug: 'bath'),
      CategoryView(id: 'living', name: 'الاستقبال', slug: 'living'),
    ];
  }

  @override
  Future<ProductDetailView> fetchProductDetail(String productId) async {
    final ProductSummaryView summary = (await fetchProducts()).firstWhere((ProductSummaryView item) => item.id == productId);
    return ProductDetailView(
      id: summary.id,
      sku: summary.sku,
      slug: summary.slug,
      name: summary.name,
      subtitle: summary.subtitle,
      thumbnail: summary.thumbnail,
      price: summary.price,
      compareAtPrice: summary.compareAtPrice,
      stockStatus: summary.stockStatus,
      gallery: const <ImageView>[
        ImageView(url: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1200'),
        ImageView(url: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1201'),
      ],
      description: 'نسيج هادئ بملمس ناعم وتشطيب أنيق مناسب للأجواء الهادئة والفاخرة.',
      configurableOptions: const <ConfigurableOptionView>[
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
            ConfigurableValueView(value: 'ivory', label: 'عاجي', available: false),
          ],
        ),
      ],
    );
  }

  @override
  Future<List<ProductSummaryView>> fetchProducts({
    String? categoryId,
    String? query,
    String sort = 'featured',
  }) async {
    final List<ProductSummaryView> items = const <ProductSummaryView>[
      ProductSummaryView(
        id: 'sku-100',
        sku: 'KL-100',
        slug: 'serene-sheet-set',
        name: 'طقم سرير سيرين',
        subtitle: 'قطن ناعم بلمسة فندقية',
        thumbnail: ImageView(url: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=900'),
        price: MoneyView(amount: 399, currencyCode: 'SAR', formatted: '399 ر.س'),
        compareAtPrice: MoneyView(amount: 499, currencyCode: 'SAR', formatted: '499 ر.س'),
        stockStatus: 'in_stock',
      ),
      ProductSummaryView(
        id: 'sku-101',
        sku: 'KL-101',
        slug: 'calm-duvet-cover',
        name: 'غطاء لحاف كالم',
        subtitle: 'نقش هادئ وتشطيب فاخر',
        thumbnail: ImageView(url: 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=900'),
        price: MoneyView(amount: 520, currencyCode: 'SAR', formatted: '520 ر.س'),
        stockStatus: 'low_stock',
      ),
      ProductSummaryView(
        id: 'sku-102',
        sku: 'KL-102',
        slug: 'bath-towel-signature',
        name: 'منشفة سيغنتشر',
        subtitle: 'سماكة مريحة وامتصاص عالٍ',
        thumbnail: ImageView(url: 'https://images.unsplash.com/photo-1631049035182-249067d7618e?w=900'),
        price: MoneyView(amount: 129, currencyCode: 'SAR', formatted: '129 ر.س'),
        stockStatus: 'in_stock',
      ),
    ];
    final String normalized = (query ?? '').trim().toLowerCase();
    final Iterable<ProductSummaryView> filtered = normalized.isEmpty
        ? items
        : items.where((ProductSummaryView item) => item.name.toLowerCase().contains(normalized) || item.subtitle!.toLowerCase().contains(normalized));
    return filtered.toList(growable: false);
  }
}
