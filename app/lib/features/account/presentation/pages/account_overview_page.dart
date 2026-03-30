import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/design_system/theme/app_colors.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/account/application/account_controller.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';
import 'package:karaz_linen_app/features/account/presentation/widgets/account_status_card.dart';
import 'package:karaz_linen_app/features/account/presentation/widgets/account_section_tile.dart';
import 'package:karaz_linen_app/features/account/presentation/widgets/profile_summary_card.dart';

class AccountOverviewPage extends ConsumerWidget {
  const AccountOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProtectedAsyncState profileState = ref.watch(accountProfileStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'لوحة الحساب',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'كل ما يخص الملف الشخصي والعناوين والطلبات في مكان واحد.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            switch (profileState.status) {
              ProtectedAsyncStatus.requiresAuth => AccountStatusCard(
                  title: 'الوصول إلى الحساب يتطلب تسجيل الدخول',
                  message: profileState.message ?? 'يرجى تسجيل الدخول للمتابعة.',
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
                  message: profileState.message ?? 'تعذر تحميل الملف الشخصي',
                  onRetry: () => ref.invalidate(profileProvider),
                ),
              ProtectedAsyncStatus.empty => AccountStatusCard(
                  title: 'بيانات الحساب غير متاحة',
                  message: profileState.message ?? 'لا توجد بيانات ملف شخصي متاحة حاليًا.',
                  icon: Icons.person_off_outlined,
                ),
              ProtectedAsyncStatus.ready => Column(
                  children: <Widget>[
                    ProfileSummaryCard(profile: profileState.data!),
                    const SizedBox(height: AppSpacing.lg),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('الوصول السريع', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'ابدئي بإدارة بيانات الحساب والعناوين قبل الانتقال إلى الطلبات.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedInk),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AccountSectionTile(
                            icon: Icons.location_on_outlined,
                            title: 'العناوين',
                            subtitle: 'إدارة عناوين الشحن والفوترة',
                            onTap: () => context.push('/account/addresses'),
                          ),
                          const Divider(),
                          AccountSectionTile(
                            icon: Icons.receipt_long_outlined,
                            title: 'الطلبات',
                            subtitle: 'المسار التالي بعد تثبيت account shell',
                            onTap: () => context.push('/account/orders'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }
}
