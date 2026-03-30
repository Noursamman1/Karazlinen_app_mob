import 'package:flutter/material.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
  });

  final AddressView address;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.sm,
            children: <Widget>[
              Text('${address.firstName} ${address.lastName}', style: Theme.of(context).textTheme.titleLarge),
              if (address.isDefaultShipping)
                const Chip(
                  label: Text('افتراضي للشحن'),
                  backgroundColor: AppColors.mist,
                ),
              if (address.isDefaultBilling)
                const Chip(
                  label: Text('افتراضي للفوترة'),
                  backgroundColor: AppColors.mist,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(address.streetLines.join('، ')),
          Text('${address.city} ${address.region ?? ''}'),
          Text(address.postcode),
          const SizedBox(height: AppSpacing.xs),
          Text(address.phone),
        ],
      ),
    );
  }
}
