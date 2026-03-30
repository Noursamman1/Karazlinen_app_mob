import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_result.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_state.dart';
import 'package:karaz_linen_app/features/catalog/presentation/widgets/product_card.dart';
import 'package:karaz_linen_app/features/search/application/search_controller.dart';
import 'package:karaz_linen_app/features/search/presentation/widgets/search_filter_bar.dart';
import 'package:karaz_linen_app/features/search/presentation/widgets/search_toolbar.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CatalogFilterState filters = ref.watch(searchFilterProvider);
    final AsyncValue<CatalogProductListing> listing = ref.watch(searchListingProvider);
    final int activeFilterCount = ref.watch(searchActiveFilterCountProvider);

    if (_controller.text != filters.query) {
      _controller.value = _controller.value.copyWith(
        text: filters.query,
        selection: TextSelection.collapsed(offset: filters.query.length),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('البحث')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          SearchToolbar(
            controller: _controller,
            onChanged: (String value) {
              updateSearchQuery(ref, value);
              setState(() {});
            },
            onClear: () {
              _controller.clear();
              updateSearchQuery(ref, '');
              setState(() {});
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  filters.query.trim().isEmpty ? 'بحث سريع ومرتب' : 'نتائج "${filters.query.trim()}"',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  filters.query.trim().isEmpty
                      ? 'ابدئي بكلمة مفتاحية أو استكشفي النتائج الحالية مع الفرز والتصفية.'
                      : 'النتائج الحالية مبنية على بيانات baseline محلية ومتوافقة مع عقود الـBFF الحالية.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SearchResultsToolbar(
            selectedSort: filters.sort.apiValue,
            activeFilterCount: activeFilterCount,
            onClearFilters: activeFilterCount == 0 ? null : () => clearSearchFilters(ref),
            onSortChanged: (String? value) {
              if (value != null) {
                updateSearchSort(ref, value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          listing.when(
            data: (CatalogProductListing data) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (data.filters.isNotEmpty)
                    SearchFilterBar(
                      filters: data.filters,
                      selectedFilters: filters.selectedFilters,
                      onToggleFilter: (String code, String value) {
                        toggleSearchFilter(ref, code, value);
                      },
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    filters.query.trim().isEmpty
                        ? '${data.meta.totalItems} منتجًا مقترحًا'
                        : '${data.meta.totalItems} نتيجة مطابقة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (data.items.isEmpty)
                    const EmptyStateCard(message: 'لا توجد نتائج مطابقة. جرّبي تعديل الكلمات أو الفلاتر.')
                  else
                    Column(
                      children: data.items
                          .map(
                            (ProductSummaryView item) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: SizedBox(
                                height: 308,
                                child: ProductCard(
                                  product: item,
                                  onTap: () => context.push('/product/${item.id}'),
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => ErrorStateCard(
              message: 'تعذر تنفيذ البحث',
              onRetry: () => ref.invalidate(searchListingProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsToolbar extends StatelessWidget {
  const _SearchResultsToolbar({
    required this.selectedSort,
    required this.activeFilterCount,
    required this.onSortChanged,
    this.onClearFilters,
  });

  final String selectedSort;
  final int activeFilterCount;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            activeFilterCount == 0 ? 'لا توجد فلاتر مفعلة' : '$activeFilterCount فلترًا مفعّلًا',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (onClearFilters != null)
          TextButton(
            onPressed: onClearFilters,
            child: const Text('مسح الفلاتر'),
          ),
        DropdownButton<String>(
          value: selectedSort,
          borderRadius: BorderRadius.circular(18),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem(value: 'featured', child: Text('الأبرز')),
            DropdownMenuItem(value: 'price_asc', child: Text('الأقل سعرًا')),
            DropdownMenuItem(value: 'price_desc', child: Text('الأعلى سعرًا')),
          ],
          onChanged: onSortChanged,
        ),
      ],
    );
  }
}
