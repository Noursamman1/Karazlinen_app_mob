import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/account/presentation/widgets/account_status_card.dart';
import 'package:karaz_linen_app/features/address_book/application/address_book_controller.dart';
import 'package:karaz_linen_app/features/address_book/presentation/widgets/address_card.dart';

class AddressBookPage extends ConsumerWidget {
  const AddressBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProtectedAsyncState<List<AddressView>> addressesState = ref.watch(addressBookStateProvider);
    final bool showFab = addressesState.status == ProtectedAsyncStatus.ready || addressesState.status == ProtectedAsyncStatus.empty;

    return Scaffold(
      appBar: AppBar(title: const Text('العناوين')),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/account/addresses/new'),
              label: const Text('إضافة عنوان'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'دفتر العناوين',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'هذه الواجهة هي baseline لإضافة وتعديل العناوين قبل ربط write flows مع الـBFF.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            switch (addressesState.status) {
              ProtectedAsyncStatus.requiresAuth => AccountStatusCard(
                  title: 'الوصول إلى العناوين يتطلب تسجيل الدخول',
                  message: addressesState.message ?? 'يرجى تسجيل الدخول للوصول إلى دفتر العناوين.',
                  actionLabel: 'فتح شاشة الدخول',
                  onAction: () => context.go('/auth-required'),
                ),
              ProtectedAsyncStatus.loading => const SectionCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ProtectedAsyncStatus.error => ErrorStateCard(
                  message: addressesState.message ?? 'تعذر تحميل العناوين',
                  onRetry: () => ref.invalidate(addressesProvider),
                ),
              ProtectedAsyncStatus.empty => Column(
                  children: <Widget>[
                    AccountStatusCard(
                      title: 'لا توجد عناوين محفوظة بعد',
                      message: addressesState.message ?? 'أضيفي عنوان الشحن الأول لتسريع إتمام الطلب لاحقًا.',
                      icon: Icons.location_off_outlined,
                      actionLabel: 'إضافة عنوان جديد',
                      onAction: () => context.push('/account/addresses/new'),
                    ),
                  ],
                ),
              ProtectedAsyncStatus.ready => Column(
                  children: <Widget>[
                    for (final AddressView address in addressesState.data!) ...<Widget>[
                      AddressCard(
                        address: address,
                        onEdit: () => context.push('/account/addresses/new', extra: address),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }
}
