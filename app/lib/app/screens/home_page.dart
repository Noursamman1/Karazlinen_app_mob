import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_localizations.dart';
import '../../design_system/theme/app_spacing.dart';
import '../../design_system/widgets/app_surface_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.brandName)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ListView(
          children: [
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.homeTitle, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.homeSubtitle),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                FilledButton(
                  onPressed: () => context.go('/catalog'),
                  child: Text(l10n.catalog),
                ),
                OutlinedButton(
                  onPressed: () => context.go('/search'),
                  child: Text(l10n.search),
                ),
                OutlinedButton(
                  onPressed: () => context.go('/account'),
                  child: Text(l10n.account),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
