import 'package:flutter/material.dart';

import '../../../../design_system/theme/app_spacing.dart';
import '../../domain/product_models.dart';

class ConfigurableOptionSelector extends StatelessWidget {
  const ConfigurableOptionSelector({
    super.key,
    required this.option,
    required this.selectedValue,
    required this.onSelected,
  });

  final ConfigurableOptionModel option;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(option.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: option.values
              .map(
                (value) => ChoiceChip(
                  label: Text(value.label),
                  selected: selectedValue == value.value,
                  onSelected: value.available ? (_) => onSelected(value.value) : null,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
