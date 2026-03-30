import 'package:flutter/material.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';

class ConfigurableOptionSection extends StatelessWidget {
  const ConfigurableOptionSection({
    super.key,
    required this.option,
    required this.selectedValue,
    required this.onValueSelected,
  });

  final ConfigurableOptionView option;
  final String? selectedValue;
  final ValueChanged<String> onValueSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(option.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: option.values.map((ConfigurableValueView value) {
            return ChoiceChip(
              label: Text(value.label),
              selected: selectedValue == value.value,
              onSelected: value.available ? (_) => onValueSelected(value.value) : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}
