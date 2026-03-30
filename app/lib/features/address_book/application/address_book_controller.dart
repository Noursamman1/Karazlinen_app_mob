import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/features/account/application/account_controller.dart';
import 'package:karaz_linen_app/features/account/application/account_use_cases.dart';
import 'package:karaz_linen_app/features/account/application/protected_state_mapper.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';

final addressesProvider = FutureProvider<List<AddressView>>((Ref ref) {
  return ref.watch(loadAddressBookUseCaseProvider).call();
});

final Provider<ProtectedAsyncState<List<AddressView>>> addressBookStateProvider =
    Provider<ProtectedAsyncState<List<AddressView>>>((Ref ref) {
  final access = ref.watch(accountAccessStateProvider);
  if (!access.canAccessProtectedData) {
    return ProtectedAsyncState<List<AddressView>>.requiresAuth(access.guardMessage);
  }

  return mapProtectedAsyncState<List<AddressView>>(
    access: access,
    asyncValue: ref.watch(addressesProvider),
    isEmpty: (List<AddressView> value) => value.isEmpty,
    emptyMessage: 'لا توجد عناوين محفوظة بعد.',
    errorMessage: 'تعذر تحميل العناوين',
  );
});
