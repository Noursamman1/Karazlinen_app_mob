import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/core/session/session_state.dart';

enum AccountAccessStatus {
  requiresSignIn,
  sessionExpired,
  authenticated,
}

class AccountAccessState {
  const AccountAccessState({
    required this.status,
    this.profile,
  });

  final AccountAccessStatus status;
  final ProfileView? profile;

  bool get canAccessProtectedData => status == AccountAccessStatus.authenticated && profile != null;

  String get guardMessage {
    switch (status) {
      case AccountAccessStatus.sessionExpired:
        return 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى للمتابعة.';
      case AccountAccessStatus.authenticated:
        return '';
      case AccountAccessStatus.requiresSignIn:
        return 'تسجيل الدخول مطلوب للوصول إلى الحساب والطلبات والعناوين.';
    }
  }

  factory AccountAccessState.fromSession(SessionState session) {
    switch (session.status) {
      case SessionStatus.authenticated:
        return AccountAccessState(
          status: AccountAccessStatus.authenticated,
          profile: session.profile,
        );
      case SessionStatus.expired:
        return AccountAccessState(
          status: AccountAccessStatus.sessionExpired,
          profile: session.profile,
        );
      case SessionStatus.unauthenticated:
        return const AccountAccessState(status: AccountAccessStatus.requiresSignIn);
    }
  }
}
