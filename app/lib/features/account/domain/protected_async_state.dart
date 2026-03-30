enum ProtectedAsyncStatus {
  requiresAuth,
  loading,
  empty,
  ready,
  error,
}

class ProtectedAsyncState<T> {
  const ProtectedAsyncState._({
    required this.status,
    this.data,
    this.message,
  });

  const ProtectedAsyncState.requiresAuth(String message)
      : this._(
          status: ProtectedAsyncStatus.requiresAuth,
          message: message,
        );

  const ProtectedAsyncState.loading()
      : this._(
          status: ProtectedAsyncStatus.loading,
        );

  const ProtectedAsyncState.empty(String message)
      : this._(
          status: ProtectedAsyncStatus.empty,
          message: message,
        );

  const ProtectedAsyncState.ready(T data)
      : this._(
          status: ProtectedAsyncStatus.ready,
          data: data,
        );

  const ProtectedAsyncState.error(String message)
      : this._(
          status: ProtectedAsyncStatus.error,
          message: message,
        );

  final ProtectedAsyncStatus status;
  final T? data;
  final String? message;

  bool get isReady => status == ProtectedAsyncStatus.ready && data != null;
}
