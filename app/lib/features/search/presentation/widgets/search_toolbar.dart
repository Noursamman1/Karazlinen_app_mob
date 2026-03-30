import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/i18n/app_localizations.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/features/search/application/search_controller.dart';

class SearchToolbar extends ConsumerWidget {
  const SearchToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final String query = ref.watch(searchControllerProvider);
    return TextField(
      controller: TextEditingController(text: query)
        ..selection = TextSelection.collapsed(offset: query.length),
      onChanged: ref.read(searchControllerProvider.notifier).updateQuery,
      decoration: InputDecoration(
        hintText: localizations.text('searchHint'),
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      ),
    );
  }
}
