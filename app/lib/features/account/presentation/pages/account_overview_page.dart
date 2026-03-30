import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:karaz_linen_app/core/presentation/async_feedback.dart';
import 'package:karaz_linen_app/core/session/session_controller.dart';
import 'package:karaz_linen_app/core/session/session_state.dart';
import 'package:karaz_linen_app/design_system/theme/app_spacing.dart';
import 'package:karaz_linen_app/design_system/widgets/section_card.dart';
import 'package:karaz_linen_app/features/account/application/account_controller.dart';
import 'package:karaz_linen_app/features/account/presentation/widgets/account_section_tile.dart';
import 'package:karaz_linen_app/features/account/presentation/widgets/profile_summary_card.dart';

class AccountOverviewPage extends ConsumerWidget {
  const AccountOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionState session = ref.watch(sessionControllerProvider);
    if (!session.isAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('تسجيل الدخول مطلوب')),
      );
    }

    final AsyncValue profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          profile.when(
            data: (dynamic value) => ProfileSummaryCard(profile: value),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => ErrorStateCard(
              message: 'تعذر تحميل الملف الشخصي',
              onRetry: () => ref.invalidate(profileProvider),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            child: Column(
              children: <Widget>[
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
                  subtitle: 'متابعة الحالة وتفاصيل الطلب',
                  onTap: () => context.push('/account/orders'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
