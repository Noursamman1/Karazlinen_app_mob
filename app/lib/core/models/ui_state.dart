sealed class UiState<T> {
  const UiState();

  factory UiState.loading() = UiLoading<T>;
  factory UiState.data(T value) = UiData<T>;
  factory UiState.empty() = UiEmpty<T>;
  factory UiState.error(String message) = UiError<T>;
}

class UiLoading<T> extends UiState<T> {
  const UiLoading();
}

class UiData<T> extends UiState<T> {
  const UiData(this.value);

  final T value;
}

class UiEmpty<T> extends UiState<T> {
  const UiEmpty();
}

class UiError<T> extends UiState<T> {
  const UiError(this.message);

  final String message;
}
