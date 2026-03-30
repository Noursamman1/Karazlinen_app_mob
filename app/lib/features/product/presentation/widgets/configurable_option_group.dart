import 'package:flutter/material.dart';

import 'package:karaz_linen_app/core/models/commerce_models.dart';

class ConfigurableOptionGroup extends StatelessWidget {
  const ConfigurableOptionGroup({
    super.key,
    required this.option,
    required this.selectedValue,
    required this.onSelected,
  });

  final ConfigurableOptionView option;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(option.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: option.values
              .map(
                (ConfigurableValueView value) => ChoiceChip(
                  label: Text(value.label),
                  selected: selectedValue == value.value,
                  onSelected: value.available ? (_) => onSelected(value.value) : null,
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
