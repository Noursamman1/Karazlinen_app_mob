import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/product/application/product_controller.dart';
import 'package:karaz_linen_app/features/product/presentation/widgets/configurable_option_section.dart';

class ProductDetailsPage extends ConsumerWidget {
  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue product = ref.watch(productDetailsProvider(productId));
    final Map<String, String> selected = ref.watch(productSelectionProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المنتج')),
      body: product.when(
        data: (dynamic data) {
          final detail = data;
          final bool allSelected = detail.configurableOptions.every(
            (dynamic option) => selected.containsKey(option.code),
          );
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              SizedBox(
                height: 280,
                child: PageView(
                  children: detail.gallery.map<Widget>((dynamic image) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(image.url, fit: BoxFit.cover),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(detail.name, style: Theme.of(context).textTheme.headlineMedium),
              if (detail.subtitle != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(detail.subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(detail.price.formatted, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                detail.stockStatus == 'out_of_stock' ? 'غير متوفر' : 'متوفر',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: detail.stockStatus == 'out_of_stock'
                          ? AppColors.danger
                          : AppColors.success,
                    ),
              ),
              if (detail.description != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                SectionCard(child: Text(detail.description!)),
              ],
              const SizedBox(height: AppSpacing.lg),
              for (final dynamic option in detail.configurableOptions) ...<Widget>[
                ConfigurableOptionSection(
                  option: option,
                  selectedValue: selected[option.code],
                  onValueSelected: (String value) {
                    ref.read(productSelectionProvider(productId).notifier).select(option.code, value);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              FilledButton(
                onPressed: allSelected ? () {} : null,
                child: Text(allSelected ? 'إضافة إلى السلة قريبًا' : 'اختاري الخيارات المطلوبة أولاً'),
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
