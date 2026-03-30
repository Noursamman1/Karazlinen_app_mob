import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/features/account/domain/account_access_state.dart';
import 'package:karaz_linen_app/features/account/domain/protected_async_state.dart';

ProtectedAsyncState<T> mapProtectedAsyncState<T>({
  required AccountAccessState access,
  required AsyncValue<T> asyncValue,
  required bool Function(T value) isEmpty,
  required String emptyMessage,
  required String errorMessage,
}) {
  if (!access.canAccessProtectedData) {
    return ProtectedAsyncState<T>.requiresAuth(access.guardMessage);
  }

  return asyncValue.when(
    data: (T value) {
      if (isEmpty(value)) {
        return ProtectedAsyncState<T>.empty(emptyMessage);
      }
      return ProtectedAsyncState<T>.ready(value);
    },
    loading: () => const ProtectedAsyncState<T>.loading(),
    error: (_, __) => ProtectedAsyncState<T>.error(errorMessage),
  );
}
