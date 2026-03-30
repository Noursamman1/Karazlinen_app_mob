import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/repositories/catalog_repository.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_query.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_result.dart';

class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository({
    List<CategoryView>? categories,
    CatalogProductListing? listing,
    ProductDetailView? detail,
    this.categoriesError,
    this.listingError,
    this.detailError,
  })  : categories = categories ?? sampleCategories,
        listing = listing ?? sampleListing,
        detail = detail ?? sampleProductDetail;

  final List<CategoryView> categories;
  final CatalogProductListing listing;
  final ProductDetailView detail;
  final Object? categoriesError;
  final Object? listingError;
  final Object? detailError;

  static const List<CategoryView> sampleCategories = <CategoryView>[
    CategoryView(id: 'sheets', name: 'أغطية السرير', slug: 'sheets'),
  ];

  static const CatalogProductListing sampleListing = CatalogProductListing(
    items: <ProductSummaryView>[
      ProductSummaryView(
        id: 'sku-100',
        sku: 'KL-100',
        slug: 'serene-sheet-set',
        name: 'طقم سرير سيرين',
        subtitle: 'قطن ناعم',
        price: MoneyView(amount: 399, currencyCode: 'SAR', formatted: '399 ر.س'),
        stockStatus: 'in_stock',
      ),
    ],
    meta: CatalogPageMeta(page: 1, pageSize: 24, totalItems: 1, totalPages: 1),
    filters: <CatalogFilterGroup>[
      CatalogFilterGroup(
        code: 'material',
        label: 'الخامة',
        values: <CatalogFilterValue>[
          CatalogFilterValue(value: 'قطن', label: 'قطن', count: 1),
        ],
      ),
    ],
  );

  static const ProductDetailView sampleProductDetail = ProductDetailView(
    id: 'sku-100',
    sku: 'KL-100',
    slug: 'serene-sheet-set',
    name: 'طقم سرير سيرين',
    subtitle: 'قطن ناعم',
    price: MoneyView(amount: 399, currencyCode: 'SAR', formatted: '399 ر.س'),
    stockStatus: 'in_stock',
    gallery: <ImageView>[],
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
    variantResolution: VariantResolutionView(
      mode: 'resolved_combinations',
      combinations: <ResolvedVariantCombinationView>[
        ResolvedVariantCombinationView(
          selection: <String, String>{'size': 'queen', 'color': 'sand'},
          resolvedSku: 'KL-100-Q-SND',
          availability: 'in_stock',
          price: MoneyView(amount: 429, currencyCode: 'SAR', formatted: '429 ر.س'),
        ),
        ResolvedVariantCombinationView(
          selection: <String, String>{'size': 'king', 'color': 'sand'},
          resolvedSku: 'KL-100-K-SND',
          availability: 'out_of_stock',
          price: MoneyView(amount: 459, currencyCode: 'SAR', formatted: '459 ر.س'),
        ),
      ],
    ),
    description: 'منتج اختباري لتغطية widget tests.',
  );

  @override
  Future<List<CategoryView>> fetchCategories() async {
    if (categoriesError != null) {
      throw categoriesError!;
    }
    return categories;
  }

  @override
  Future<CatalogProductListing> fetchProductListing(CatalogProductQuery query) async {
    if (listingError != null) {
      throw listingError!;
    }
    return listing;
  }

  @override
  Future<ProductDetailView> fetchProductDetail(String productIdOrSlug) async {
    if (detailError != null) {
      throw detailError!;
    }
    return detail;
  }
}
