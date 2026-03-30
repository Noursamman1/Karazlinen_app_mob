import 'package:flutter/material.dart';

import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/features/catalog/domain/catalog_query.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.filters,
    required this.selectedFilters,
    required this.onToggleFilter,
  });

  final List<CatalogFilterGroup> filters;
  final Map<String, Set<String>> selectedFilters;
  final void Function(String code, String value) onToggleFilter;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filters
          .map(
            (CatalogFilterGroup group) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(group.label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: group.values
                        .map(
                          (CatalogFilterValue value) => FilterChip(
                            label: Text('${value.label} (${value.count})'),
                            selected: selectedFilters[group.code]?.contains(value.value) ?? false,
                            onSelected: (_) => onToggleFilter(group.code, value.value),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
