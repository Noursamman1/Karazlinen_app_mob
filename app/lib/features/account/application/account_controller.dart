import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/di/service_locator.dart';
import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/features/account/application/account_use_cases.dart';
import 'package:karaz_linen_app/features/account/application/protected_state_mapper.dart';
import 'package:karaz_linen_app/features/account/domain/account_access_state.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';

final Provider<AccountAccessState> accountAccessStateProvider = Provider<AccountAccessState>((Ref ref) {
  return AccountAccessState.fromSession(ref.watch(sessionControllerProvider));
});

final profileProvider = FutureProvider<ProfileView>((Ref ref) {
  return ref.watch(loadAccountProfileUseCaseProvider).call();
});

final Provider<ProtectedAsyncState<ProfileView>> accountProfileStateProvider =
    Provider<ProtectedAsyncState<ProfileView>>((Ref ref) {
  final AccountAccessState access = ref.watch(accountAccessStateProvider);
  if (!access.canAccessProtectedData) {
    return ProtectedAsyncState<ProfileView>.requiresAuth(access.guardMessage);
  }

  return mapProtectedAsyncState<ProfileView>(
    access: access,
    asyncValue: ref.watch(profileProvider),
    isEmpty: (_) => false,
    emptyMessage: 'لا توجد بيانات ملف شخصي متاحة حاليًا.',
    errorMessage: 'تعذر تحميل الملف الشخصي',
  );
});
