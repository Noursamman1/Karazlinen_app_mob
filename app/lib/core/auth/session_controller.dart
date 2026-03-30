import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_state.dart';

class SessionController extends StateNotifier<SessionState> {
  SessionController() : super(const SessionState.guest());

  void authenticate(String customerName) {
    state = SessionState(isAuthenticated: true, customerName: customerName);
  }

  void logout() {
    state = const SessionState.guest();
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController();
});
