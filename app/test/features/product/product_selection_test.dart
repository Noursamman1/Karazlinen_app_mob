import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/product/application/product_controller.dart';
import 'package:karaz_linen_app/features/product/domain/product_selection.dart';

void main() {
  test('product selection tracks chosen values', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ProductSelectionController notifier = container.read(
      productSelectionProvider('sku-100').notifier,
    );
    notifier.select('size', 'queen');

    expect(
      container.read(productSelectionProvider('sku-100')).selectedValues['size'],
      'queen',
    );
  });

  test('selection summary resolves the exact variant combination', () {
    const ProductDetailView detail = ProductDetailView(
      id: 'sku-100',
      sku: 'KL-100',
      slug: 'serene-sheet-set',
      name: 'طقم سرير سيرين',
      subtitle: 'قطن ناعم',
      price: MoneyView(amount: 399, currencyCode: 'SAR', formatted: '399 ر.س'),
      stockStatus: 'in_stock',
      gallery: <ImageView>[ImageView(url: 'https://example.com/base-image.jpg')],
      configurableOptions: <ConfigurableOptionView>[
        ConfigurableOptionView(
          code: 'size',
          label: 'المقاس',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'queen', label: 'كوين', available: true),
          ],
        ),
        ConfigurableOptionView(
          code: 'color',
          label: 'اللون',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'sand', label: 'رملي', available: true),
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
            image: ImageView(url: 'https://example.com/variant-image.jpg'),
            price: MoneyView(amount: 429, currencyCode: 'SAR', formatted: '429 ر.س'),
          ),
        ],
      ),
    );

    const ProductSelectionState selection = ProductSelectionState(
      selectedValues: <String, String>{'size': 'queen', 'color': 'sand'},
    );

    final ProductSelectionSummary summary = ProductSelectionSummary.fromProduct(detail, selection);

    expect(summary.allRequiredSelected, isTrue);
    expect(summary.isPlaceholder, isFalse);
    expect(summary.isResolved, isTrue);
    expect(summary.previewSku, 'KL-100-Q-SND');
    expect(summary.previewPrice.formatted, '429 ر.س');
    expect(summary.previewImage?.url, 'https://example.com/variant-image.jpg');
  });

  test('selection summary stays provisional while options are incomplete', () {
    const ProductDetailView detail = ProductDetailView(
      id: 'sku-100',
      sku: 'KL-100',
      slug: 'serene-sheet-set',
      name: 'طقم سرير سيرين',
      subtitle: 'قطن ناعم',
      price: MoneyView(amount: 399, currencyCode: 'SAR', formatted: '399 ر.س'),
      stockStatus: 'in_stock',
      gallery: <ImageView>[ImageView(url: 'https://example.com/base-image.jpg')],
      configurableOptions: <ConfigurableOptionView>[
        ConfigurableOptionView(
          code: 'size',
          label: 'المقاس',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'queen', label: 'كوين', available: true),
          ],
        ),
        ConfigurableOptionView(
          code: 'color',
          label: 'اللون',
          values: <ConfigurableValueView>[
            ConfigurableValueView(value: 'sand', label: 'رملي', available: true),
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
        ],
      ),
    );

    const ProductSelectionState selection = ProductSelectionState(
      selectedValues: <String, String>{'size': 'queen'},
    );

    final ProductSelectionSummary summary = ProductSelectionSummary.fromProduct(detail, selection);

    expect(summary.allRequiredSelected, isFalse);
    expect(summary.isPlaceholder, isTrue);
    expect(summary.isResolved, isFalse);
  });

  test('selection summary falls back safely for non-matching selection', () {
    const ProductDetailView detail = ProductDetailView(
      id: 'sku-100',
      sku: 'KL-100',
      slug: 'serene-sheet-set',
      name: 'طقم سرير سيرين',
      subtitle: 'قطن ناعم',
      price: MoneyView(amount: 399, currencyCode: 'SAR', formatted: '399 ر.س'),
      stockStatus: 'in_stock',
      gallery: <ImageView>[ImageView(url: 'https://example.com/base-image.jpg')],
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
        unresolvedReason: 'Missing combination from BFF payload.',
        combinations: <ResolvedVariantCombinationView>[
          ResolvedVariantCombinationView(
            selection: <String, String>{'size': 'queen', 'color': 'sand'},
            resolvedSku: 'KL-100-Q-SND',
            availability: 'in_stock',
            price: MoneyView(amount: 429, currencyCode: 'SAR', formatted: '429 ر.س'),
          ),
        ],
      ),
    );

    const ProductSelectionState selection = ProductSelectionState(
      selectedValues: <String, String>{'size': 'king', 'color': 'ivory'},
    );

    final ProductSelectionSummary summary = ProductSelectionSummary.fromProduct(detail, selection);

    expect(summary.allRequiredSelected, isTrue);
    expect(summary.isResolved, isFalse);
    expect(summary.isPlaceholder, isTrue);
    expect(summary.headline, 'الاختيار لا يطابق combination معروفًا بعد');
  });
}
