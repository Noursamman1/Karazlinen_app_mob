import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/features/catalog/application/catalog_controller.dart';
import 'package:karaz_linen_app/features/catalog/presentation/widgets/category_strip.dart';
import 'package:karaz_linen_app/features/catalog/presentation/widgets/product_card.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue categories = ref.watch(catalogCategoriesProvider);
    final AsyncValue products = ref.watch(catalogProductsProvider);
    final String? selectedCategoryId = ref.watch(catalogSelectedCategoryProvider);
    final String sort = ref.watch(catalogSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التصنيفات'),
        actions: <Widget>[
          IconButton(
            tooltip: 'البحث',
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text(
            'هدوء بصري ولمسة فاخرة في كل مجموعة.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          categories.when(
            data: (dynamic items) => CategoryStrip(
              categories: items as List,
              selectedCategoryId: selectedCategoryId,
              onCategorySelected: (String? value) {
                ref.read(catalogSelectedCategoryProvider.notifier).state = value;
              },
            ),
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => ErrorStateCard(
              message: 'تعذر تحميل التصنيفات',
              onRetry: () => ref.invalidate(catalogCategoriesProvider),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune),
                label: const Text('التصفية'),
              ),
              const SizedBox(width: AppSpacing.sm),
              DropdownButton<String>(
                value: sort,
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'featured', child: Text('الأبرز')),
                  DropdownMenuItem(value: 'price_asc', child: Text('السعر: الأقل أولاً')),
                  DropdownMenuItem(value: 'price_desc', child: Text('السعر: الأعلى أولاً')),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(catalogSortProvider.notifier).state = value;
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          products.when(
            data: (dynamic items) {
              final List typedItems = items as List;
              if (typedItems.isEmpty) {
                return const EmptyStateCard(message: 'لا توجد منتجات في هذا القسم حالياً');
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: typedItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return ProductCard(product: typedItems[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => ErrorStateCard(
              message: 'تعذر تحميل المنتجات',
              onRetry: () => ref.invalidate(catalogProductsProvider),
            ),
          ),
        ],
      ),
    );
  }
}
