import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karaz_linen_app/core/models/customer_models.dart';
import 'package:karaz_linen_app/core/session/session_state.dart';

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState(status: SessionStatus.unauthenticated));

  void restorePreviewSession(ProfileView profile) {
    state = SessionState(status: SessionStatus.authenticated, profile: profile);
  }

  void expireSession() {
    state = SessionState(status: SessionStatus.expired, profile: state.profile);
  }

  void signOut() {
    state = const SessionState(status: SessionStatus.unauthenticated);
  }
}
