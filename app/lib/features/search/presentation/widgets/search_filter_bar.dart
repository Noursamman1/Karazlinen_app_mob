import 'package:flutter/material.dart';

import '../../../../design_system/theme/app_spacing.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.filters,
  });

  final List<String> filters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                child: FilterChip(
                  label: Text(filter),
                  selected: false,
                  onSelected: (_) {},
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
