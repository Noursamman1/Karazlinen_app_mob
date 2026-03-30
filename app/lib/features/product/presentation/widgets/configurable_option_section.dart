import 'package:flutter/material.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';

class ConfigurableOptionSection extends StatelessWidget {
  const ConfigurableOptionSection({
    super.key,
    required this.option,
    required this.selectedValue,
    required this.onSelectionChanged,
  });

  final ConfigurableOptionView option;
  final String? selectedValue;
  final ValueChanged<String?> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(option.label, style: Theme.of(context).textTheme.titleLarge),
            ),
            Text(
              selectedValue == null ? 'مطلوب' : 'تم الاختيار',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selectedValue == null ? AppColors.warning : AppColors.success,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: option.values.map((ConfigurableValueView value) {
            final bool isSelected = selectedValue == value.value;
            return ChoiceChip(
              label: Text(value.label),
              selected: isSelected,
              onSelected: value.available
                  ? (bool selected) => onSelectionChanged(selected ? value.value : null)
                  : null,
              avatar: value.available
                  ? null
                  : const Icon(
                      Icons.block,
                      size: 16,
                      color: AppColors.danger,
                    ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}
