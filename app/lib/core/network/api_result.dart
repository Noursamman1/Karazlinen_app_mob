sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiFailure failure) failure,
  }) {
    final ApiResult<T> current = this;
    if (current is ApiSuccess<T>) {
      return success(current.data);
    }
    return failure((current as ApiError<T>).error);
  }
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

final class ApiError<T> extends ApiResult<T> {
  const ApiError(this.error);

  final ApiFailure error;
}

class ApiFailure {
  const ApiFailure({
    required this.code,
    required this.message,
    this.statusCode,
    this.retryable = false,
  });

  final String code;
  final String message;
  final int? statusCode;
  final bool retryable;
}
