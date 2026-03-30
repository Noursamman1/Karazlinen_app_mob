import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/features/catalog/application/catalog_controller.dart';

class CategoryChipStrip extends ConsumerWidget {
  const CategoryChipStrip({
    super.key,
    required this.categories,
  });

  final List<CategoryView> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? selectedCategory = ref.watch(catalogFilterProvider).categoryId;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: const Text('الكل'),
              selected: selectedCategory == null,
              onSelected: (_) => updateCatalogCategory(ref, null),
            ),
          ),
          ...categories.map(
            (CategoryView category) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: selectedCategory == category.id,
                onSelected: (_) => updateCatalogCategory(ref, category.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
