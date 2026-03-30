import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/features/catalog/presentation/widgets/product_card.dart';
import 'package:karaz_linen_app/features/search/application/search_controller.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController(
      text: ref.watch(searchQueryProvider),
    );
    final AsyncValue results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('البحث')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'ابحثي عن منتج أو مجموعة',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
                icon: const Icon(Icons.close),
              ),
            ),
            onChanged: (String value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          results.when(
            data: (dynamic items) {
              final List typedItems = items as List;
              if (typedItems.isEmpty) {
                return const EmptyStateCard(message: 'لا توجد نتائج مطابقة');
              }
              return Column(
                children: typedItems
                    .map<Widget>(
                      (dynamic item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: SizedBox(
                          height: 280,
                          child: ProductCard(
                            product: item,
                            onTap: () => context.push('/product/${item.id}'),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => ErrorStateCard(
              message: 'تعذر تنفيذ البحث',
              onRetry: () => ref.invalidate(searchResultsProvider),
            ),
          ),
        ],
      ),
    );
  }
}
