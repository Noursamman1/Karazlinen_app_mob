import 'package:flutter/material.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.profile,
  });

  final ProfileView profile;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(profile.fullName, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(profile.email),
          if (profile.phone != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(profile.phone!),
          ],
        ],
      ),
    );
  }
}
