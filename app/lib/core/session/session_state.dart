import 'package:karaz_linen_app/core/models/customer_models.dart';

enum SessionStatus { unauthenticated, authenticated, expired }

class SessionState {
  const SessionState({
    required this.status,
    this.profile,
  });

  final SessionStatus status;
  final ProfileView? profile;

  bool get isAuthenticated => status == SessionStatus.authenticated && profile != null;

  SessionState copyWith({
    SessionStatus? status,
    ProfileView? profile,
  }) {
    return SessionState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
    );
  }
}
