import 'package:karaz_linen_app/core/models/commerce_models.dart';

class ProductSelectionState {
  const ProductSelectionState({
    this.selectedValues = const <String, String>{},
  });

  final Map<String, String> selectedValues;

  bool isSelected(String code, String value) {
    return selectedValues[code] == value;
  }

  ProductSelectionState select(String code, String value) {
    return ProductSelectionState(
      selectedValues: <String, String>{
        ...selectedValues,
        code: value,
      },
    );
  }

  ProductSelectionState clear(String code) {
    final Map<String, String> next = <String, String>{...selectedValues}..remove(code);
    return ProductSelectionState(selectedValues: next);
  }
}

enum ProductVariantPreviewMode {
  baseProduct,
  resolvedCombination,
  incompleteSelection,
  unresolvedSelection,
}

class SelectedProductOption {
  const SelectedProductOption({
    required this.code,
    required this.label,
    required this.value,
    required this.valueLabel,
  });

  final String code;
  final String label;
  final String value;
  final String valueLabel;
}

class ProductSelectionSummary {
  const ProductSelectionSummary({
    required this.selectedOptions,
    required this.missingOptionLabels,
    required this.previewMode,
    required this.previewSku,
    required this.previewPrice,
    required this.previewAvailabilityCode,
    required this.previewAvailabilityLabel,
    required this.previewImage,
    required this.headline,
    required this.helperText,
    required this.isPlaceholder,
  });

  final List<SelectedProductOption> selectedOptions;
  final List<String> missingOptionLabels;
  final ProductVariantPreviewMode previewMode;
  final String previewSku;
  final MoneyView previewPrice;
  final String previewAvailabilityCode;
  final String previewAvailabilityLabel;
  final ImageView? previewImage;
  final String headline;
  final String helperText;
  final bool isPlaceholder;

  bool get allRequiredSelected => missingOptionLabels.isEmpty;
  bool get isResolved => previewMode == ProductVariantPreviewMode.resolvedCombination;
  bool get isPurchasable => allRequiredSelected && previewAvailabilityCode != 'out_of_stock';

  factory ProductSelectionSummary.fromProduct(
    ProductDetailView detail,
    ProductSelectionState selection,
  ) {
    final List<SelectedProductOption> selectedOptions = detail.configurableOptions
        .where((ConfigurableOptionView option) => selection.selectedValues.containsKey(option.code))
        .map((ConfigurableOptionView option) {
          final String selectedValue = selection.selectedValues[option.code]!;
          final ConfigurableValueView resolvedValue = option.values.firstWhere(
            (ConfigurableValueView value) => value.value == selectedValue,
            orElse: () => ConfigurableValueView(
              value: selectedValue,
              label: selectedValue,
              available: true,
            ),
          );
          return SelectedProductOption(
            code: option.code,
            label: option.label,
            value: selectedValue,
            valueLabel: resolvedValue.label,
          );
        })
        .toList(growable: false);

    final List<String> missingOptionLabels = detail.configurableOptions
        .where((ConfigurableOptionView option) => !selection.selectedValues.containsKey(option.code))
        .map((ConfigurableOptionView option) => option.label)
        .toList(growable: false);

    if (detail.configurableOptions.isEmpty) {
      return ProductSelectionSummary(
        selectedOptions: selectedOptions,
        missingOptionLabels: missingOptionLabels,
        previewMode: ProductVariantPreviewMode.baseProduct,
        previewSku: detail.sku,
        previewPrice: detail.price,
        previewAvailabilityCode: detail.stockStatus,
        previewAvailabilityLabel: _availabilityLabel(detail.stockStatus),
        previewImage: detail.gallery.isEmpty ? detail.thumbnail : detail.gallery.first,
        headline: 'منتج جاهز دون خيارات إضافية',
        helperText: 'هذا المنتج لا يحتاج اختيار نسخة فرعية قبل المتابعة.',
        isPlaceholder: false,
      );
    }

    if (missingOptionLabels.isNotEmpty) {
      return ProductSelectionSummary(
        selectedOptions: selectedOptions,
        missingOptionLabels: missingOptionLabels,
        previewMode: ProductVariantPreviewMode.incompleteSelection,
        previewSku: detail.sku,
        previewPrice: detail.price,
        previewAvailabilityCode: detail.stockStatus,
        previewAvailabilityLabel: 'سيظهر التوفر النهائي بعد استكمال الاختيارات',
        previewImage: detail.gallery.isEmpty ? detail.thumbnail : detail.gallery.first,
        headline: 'اختيار النسخة غير مكتمل بعد',
        helperText: 'أكملي ${missingOptionLabels.join('، ')} لرؤية النسخة النهائية المطابقة.',
        isPlaceholder: true,
      );
    }

    ResolvedVariantCombinationView? combination;
    for (final ResolvedVariantCombinationView item in detail.variantResolution.combinations) {
      if (item.matchesSelection(selection.selectedValues)) {
        combination = item;
        break;
      }
    }

    if (combination != null) {
      return ProductSelectionSummary(
        selectedOptions: selectedOptions,
        missingOptionLabels: const <String>[],
        previewMode: ProductVariantPreviewMode.resolvedCombination,
        previewSku: combination.resolvedSku,
        previewPrice: combination.price,
        previewAvailabilityCode: combination.availability,
        previewAvailabilityLabel: _availabilityLabel(combination.availability),
        previewImage: combination.image ?? (detail.gallery.isEmpty ? detail.thumbnail : detail.gallery.first),
        headline: 'النسخة المختارة جاهزة',
        helperText: 'تمت مطابقة الاختيار مع combination نهائي من العقد canonical.',
        isPlaceholder: false,
      );
    }

    return ProductSelectionSummary(
      selectedOptions: selectedOptions,
      missingOptionLabels: const <String>[],
      previewMode: ProductVariantPreviewMode.unresolvedSelection,
      previewSku: detail.sku,
      previewPrice: detail.price,
      previewAvailabilityCode: detail.stockStatus,
      previewAvailabilityLabel: 'تعذر حسم النسخة المختارة من البيانات الحالية',
      previewImage: detail.gallery.isEmpty ? detail.thumbnail : detail.gallery.first,
      headline: 'الاختيار لا يطابق combination معروفًا بعد',
      helperText: detail.variantResolution.unresolvedReason ??
          'لم تعد هذه حالة متوقعة بعد تحديث العقد، لكنها تبقى محمية احتياطيًا إذا كانت بيانات الـBFF غير مكتملة.',
      isPlaceholder: true,
    );
  }

  static String _availabilityLabel(String stockStatus) {
    switch (stockStatus) {
      case 'out_of_stock':
        return 'غير متوفر';
      case 'low_stock':
        return 'كمية محدودة';
      default:
        return 'متوفر';
    }
  }
}
