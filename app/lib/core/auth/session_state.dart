class SessionState {
  const SessionState({
    required this.isAuthenticated,
    this.customerName,
  });

  final bool isAuthenticated;
  final String? customerName;

  const SessionState.guest() : this(isAuthenticated: false);
}
