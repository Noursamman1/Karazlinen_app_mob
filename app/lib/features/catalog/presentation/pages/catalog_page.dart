import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/catalog/application/catalog_controller.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_query.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_result.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_state.dart';
import 'package:karaz_linen_app/features/catalog/presentation/widgets/category_strip.dart';
import 'package:karaz_linen_app/features/catalog/presentation/widgets/product_card.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CategoryView>> categories = ref.watch(catalogCategoriesProvider);
    final AsyncValue<CatalogProductListing> listing = ref.watch(catalogListingProvider);
    final CatalogFilterState filters = ref.watch(catalogFilterProvider);
    final int activeFilterCount = ref.watch(catalogActiveFilterCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التصنيفات'),
        actions: <Widget>[
          IconButton(
            tooltip: 'البحث',
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          const _CatalogHeroCard(),
          const SizedBox(height: AppSpacing.lg),
          categories.when(
            data: (List<CategoryView> items) => CategoryStrip(
              categories: items,
              selectedCategoryId: filters.categoryId,
              onCategorySelected: (String? value) => updateCatalogCategory(ref, value),
            ),
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => ErrorStateCard(
              message: 'تعذر تحميل التصنيفات',
              onRetry: () => ref.invalidate(catalogCategoriesProvider),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _CatalogToolbar(
            selectedSort: filters.sort.apiValue,
            activeFilterCount: activeFilterCount,
            onOpenFilters: () => _showCatalogFiltersSheet(context, ref, listing),
            onSortChanged: (String? value) {
              if (value != null) {
                updateCatalogSort(ref, value);
              }
            },
          ),
          if (activeFilterCount > 0) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _ActiveCatalogFilters(
              filters: readAvailableCatalogFilters(ref, listing),
              selectedFilters: filters.selectedFilters,
              onToggleFilter: (String code, String value) => toggleCatalogFilter(ref, code, value),
              onClearAll: () => clearCatalogFilters(ref),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          listing.when(
            data: (CatalogProductListing data) {
              if (data.items.isEmpty) {
                return EmptyStateCard(
                  message: filters.categoryId == null
                      ? 'لا توجد منتجات مطابقة الآن. جرّبي تعديل التصفية أو البحث.'
                      : 'لا توجد منتجات في هذا التصنيف حاليًا.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${data.meta.totalItems} قطعة متاحة الآن',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return ProductCard(product: data.items[index]);
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => ErrorStateCard(
              message: 'تعذر تحميل المنتجات',
              onRetry: () => ref.invalidate(catalogListingProvider),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCatalogFiltersSheet(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<CatalogProductListing> listing,
  ) async {
    final List<CatalogFilterGroup> filters = readAvailableCatalogFilters(ref, listing);
    if (filters.isEmpty) {
      await showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'ستظهر الفلاتر التفصيلية هنا عندما يدعمها العقد والبيانات الحية بشكل كامل.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, _) {
            final CatalogFilterState state = ref.watch(catalogFilterProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'التصفية',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () => clearCatalogFilters(ref),
                            child: const Text('مسح الكل'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'الفلاتر الحالية مشتقة من بيانات demo وتعمل كواجهة baseline حتى يكتمل facet contract.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (final CatalogFilterGroup group in filters) ...<Widget>[
                        Text(group.label, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: group.values
                              .map(
                                (CatalogFilterValue value) => FilterChip(
                                  label: Text('${value.label} (${value.count})'),
                                  selected: state.selectedFilters[group.code]?.contains(value.value) ?? false,
                                  onSelected: (_) => toggleCatalogFilter(ref, group.code, value.value),
                                ),
                              )
                              .toList(growable: false),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CatalogHeroCard extends StatelessWidget {
  const _CatalogHeroCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[
              AppColors.surface,
              Color(0xFFF1E5D8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'مجموعات هادئة بتفاصيل راقية',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'استكشفي الفئات، رتّبي القطع حسب الأولوية، وابدئي من عرض واضح قبل ربط البيانات الحية.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogToolbar extends StatelessWidget {
  const _CatalogToolbar({
    required this.selectedSort,
    required this.activeFilterCount,
    required this.onOpenFilters,
    required this.onSortChanged,
  });

  final String selectedSort;
  final int activeFilterCount;
  final VoidCallback onOpenFilters;
  final ValueChanged<String?> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        FilledButton.icon(
          onPressed: onOpenFilters,
          icon: const Icon(Icons.tune),
          label: Text(activeFilterCount == 0 ? 'التصفية' : 'التصفية ($activeFilterCount)'),
        ),
        const Spacer(),
        DropdownButton<String>(
          value: selectedSort,
          borderRadius: BorderRadius.circular(18),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem(value: 'featured', child: Text('الأبرز')),
            DropdownMenuItem(value: 'price_asc', child: Text('السعر: الأقل أولاً')),
            DropdownMenuItem(value: 'price_desc', child: Text('السعر: الأعلى أولاً')),
          ],
          onChanged: onSortChanged,
        ),
      ],
    );
  }
}

class _ActiveCatalogFilters extends StatelessWidget {
  const _ActiveCatalogFilters({
    required this.filters,
    required this.selectedFilters,
    required this.onToggleFilter,
    required this.onClearAll,
  });

  final List<CatalogFilterGroup> filters;
  final Map<String, Set<String>> selectedFilters;
  final void Function(String code, String value) onToggleFilter;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final List<_ActiveCatalogFilterChipData> chips = <_ActiveCatalogFilterChipData>[
      for (final CatalogFilterGroup group in filters)
        for (final CatalogFilterValue value in group.values)
          if (selectedFilters[group.code]?.contains(value.value) ?? false)
            _ActiveCatalogFilterChipData(
              code: group.code,
              value: value.value,
              label: '${group.label}: ${value.label}',
            ),
    ];

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: chips
              .map(
                (_ActiveCatalogFilterChipData chip) => InputChip(
                  label: Text(chip.label),
                  onDeleted: () => onToggleFilter(chip.code, chip.value),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: onClearAll,
          child: const Text('مسح كل الفلاتر'),
        ),
      ],
    );
  }
}

class _ActiveCatalogFilterChipData {
  const _ActiveCatalogFilterChipData({
    required this.code,
    required this.value,
    required this.label,
  });

  final String code;
  final String value;
  final String label;
}
