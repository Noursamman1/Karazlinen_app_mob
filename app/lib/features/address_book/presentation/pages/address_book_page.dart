import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/features/address_book/application/address_book_controller.dart';
import 'package:karaz_linen_app/features/address_book/presentation/widgets/address_card.dart';

class AddressBookPage extends ConsumerWidget {
  const AddressBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue addresses = ref.watch(addressesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('العناوين')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/account/addresses/new'),
        label: const Text('إضافة عنوان'),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: addresses.when(
          data: (dynamic items) {
            final List typedItems = items as List;
            if (typedItems.isEmpty) {
              return const EmptyStateCard(message: 'لا توجد عناوين محفوظة');
            }
            return ListView.separated(
              itemCount: typedItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext context, int index) {
                return AddressCard(address: typedItems[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ErrorStateCard(
            message: 'تعذر تحميل العناوين',
            onRetry: () => ref.invalidate(addressesProvider),
          ),
        ),
      ),
    );
  }
}
