import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/product/application/product_controller.dart';
import 'package:karaz_linen_app/features/product/domain/product_selection.dart';
import 'package:karaz_linen_app/features/product/presentation/widgets/configurable_option_section.dart';

class ProductDetailsPage extends ConsumerWidget {
  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ProductDetailView> product = ref.watch(productDetailsProvider(productId));
    final ProductSelectionState selected = ref.watch(productSelectionProvider(productId));
    final AsyncValue<ProductSelectionSummary> selectionSummaryAsync = ref.watch(
      productSelectionSummaryProvider(productId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المنتج')),
      body: product.when(
        data: (ProductDetailView detail) {
          final ProductSelectionSummary selectionSummary = selectionSummaryAsync.maybeWhen(
            data: (ProductSelectionSummary summary) => summary,
            orElse: () => ProductSelectionSummary.fromProduct(detail, selected),
          );

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              _ProductGallery(
                gallery: detail.gallery,
                fallbackImage: detail.thumbnail,
                highlightedImage: selectionSummary.previewImage,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ProductHeader(detail: detail),
              if (detail.description != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                SectionCard(
                  child: Text(
                    detail.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _SelectionProgressCard(
                totalOptions: detail.configurableOptions.length,
                selectedCount: selectionSummary.selectedOptions.length,
              ),
              const SizedBox(height: AppSpacing.md),
              _SelectionSummaryCard(summary: selectionSummary),
              const SizedBox(height: AppSpacing.lg),
              for (final ConfigurableOptionView option in detail.configurableOptions) ...<Widget>[
                SectionCard(
                  child: ConfigurableOptionSection(
                    option: option,
                    selectedValue: selected.selectedValues[option.code],
                    onSelectionChanged: (String? value) {
                      final ProductSelectionController notifier = ref.read(
                        productSelectionProvider(productId).notifier,
                      );
                      if (value == null) {
                        notifier.clear(option.code);
                        return;
                      }
                      notifier.select(option.code, value);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _VariantPreviewCard(summary: selectionSummary),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: selectionSummary.isResolved && selectionSummary.isPurchasable
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              selectionSummary.isResolved
                                  ? 'تم اعتماد النسخة ${selectionSummary.previewSku} كاختيار نهائي مطابق للعقد.'
                                  : 'تم حفظ الاختيار، لكن ما زالت هناك حاجة لمراجعة بيانات الـBFF لهذه النسخة.',
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  selectionSummary.isResolved && selectionSummary.isPurchasable
                      ? 'اعتماد النسخة المختارة'
                      : selectionSummary.allRequiredSelected
                          ? 'تعذر اعتماد النسخة الحالية'
                          : 'اختاري الخيارات المطلوبة أولاً',
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateCard(
          message: 'تعذر تحميل المنتج',
          onRetry: () => ref.invalidate(productDetailsProvider(productId)),
        ),
      ),
    );
  }
}

class _ProductGallery extends StatelessWidget {
  const _ProductGallery({
    required this.gallery,
    required this.fallbackImage,
    this.highlightedImage,
  });

  final List<ImageView> gallery;
  final ImageView? fallbackImage;
  final ImageView? highlightedImage;

  @override
  Widget build(BuildContext context) {
    final List<ImageView> images = <ImageView>[
      if (highlightedImage != null) highlightedImage!,
      ...gallery.where((ImageView image) => image.url != highlightedImage?.url),
      if (gallery.isEmpty && fallbackImage != null && fallbackImage?.url != highlightedImage?.url) fallbackImage!,
    ];

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        height: 320,
        child: images.isEmpty
            ? const Center(child: Icon(Icons.photo_outlined, size: 40, color: AppColors.accent))
            : PageView(
                children: images.map((ImageView image) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(image.url, fit: BoxFit.cover),
                  );
                }).toList(growable: false),
              ),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({
    required this.detail,
  });

  final ProductDetailView detail;

  @override
  Widget build(BuildContext context) {
    final bool lowStock = detail.stockStatus == 'low_stock';
    final bool outOfStock = detail.stockStatus == 'out_of_stock';

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(detail.name, style: Theme.of(context).textTheme.headlineMedium),
          if (detail.subtitle != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(detail.subtitle!, style: Theme.of(context).textTheme.bodyLarge),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _MetaChip(
                label: detail.price.formatted,
                foreground: AppColors.ink,
                background: AppColors.accentSoft,
              ),
              if (detail.compareAtPrice != null)
                _MetaChip(
                  label: 'بدلاً من ${detail.compareAtPrice!.formatted}',
                  foreground: AppColors.mutedInk,
                  background: AppColors.surface,
                ),
              _MetaChip(
                label: outOfStock
                    ? 'غير متوفر'
                    : lowStock
                        ? 'كمية محدودة'
                        : 'متوفر',
                foreground: outOfStock ? AppColors.danger : AppColors.success,
                background: outOfStock
                    ? AppColors.surface.withValues(alpha: 0.92)
                    : AppColors.accentSoft.withValues(alpha: 0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectionProgressCard extends StatelessWidget {
  const _SelectionProgressCard({
    required this.totalOptions,
    required this.selectedCount,
  });

  final int totalOptions;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final double progress = totalOptions == 0 ? 1 : selectedCount / totalOptions;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('تقدّم الاختيار', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            totalOptions == 0
                ? 'لا توجد خيارات مطلوبة لهذا المنتج.'
                : '$selectedCount من $totalOptions خيارات مكتملة',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class _SelectionSummaryCard extends StatelessWidget {
  const _SelectionSummaryCard({
    required this.summary,
  });

  final ProductSelectionSummary summary;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(summary.headline, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(summary.helperText, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          if (summary.selectedOptions.isEmpty)
            const Text('لم يتم اختيار أي خيار بعد.')
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: summary.selectedOptions
                  .map(
                    (SelectedProductOption option) => InputChip(
                      label: Text('${option.label}: ${option.valueLabel}'),
                      onPressed: null,
                    ),
                  )
                  .toList(growable: false),
            ),
          if (summary.missingOptionLabels.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              'الخيارات الناقصة: ${summary.missingOptionLabels.join('، ')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warning),
            ),
          ],
        ],
      ),
    );
  }
}

class _VariantPreviewCard extends StatelessWidget {
  const _VariantPreviewCard({
    required this.summary,
  });

  final ProductSelectionSummary summary;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('معاينة النسخة المختارة', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: summary.previewImage == null
                      ? const DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.mist),
                          child: Icon(Icons.photo_outlined, color: AppColors.accent),
                        )
                      : Image.network(summary.previewImage!.url, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(summary.previewPrice.formatted, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text('SKU الحالي: ${summary.previewSku}', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(summary.previewAvailabilityLabel, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          if (summary.isPlaceholder) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.accentSoft.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.info_outline, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'هذه المعاينة ما زالت احتياطية فقط لأن الاختيار لم يكتمل أو لأن بيانات الـcombination المطابق لم تصل كاملة.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.accentSoft.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.check_circle_outline, color: AppColors.success),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'هذه القيم تأتي الآن من `variantResolution` المعتمد: SKU والسعر والصورة والتوفر مرتبطة بالـcombination المختار.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
