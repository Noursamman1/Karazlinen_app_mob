import 'package:flutter/material.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';

class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final List<CategoryView> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          ChoiceChip(
            label: const Text('الكل'),
            selected: selectedCategoryId == null,
            onSelected: (_) => onCategorySelected(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          for (final CategoryView category in categories) ...<Widget>[
            ChoiceChip(
              label: Text(category.name),
              selected: selectedCategoryId == category.id,
              onSelected: (_) => onCategorySelected(category.id),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
