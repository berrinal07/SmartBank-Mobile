import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/login_request.dart';
import '../../data/services/auth_service.dart';
import 'auth_provider.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthStatus> {
  AuthService get _authService => ref.read(authServiceProvider);

  @override
  AuthStatus build() {
    return AuthStatus.initial;
  }

  Future<void> login({
  required String email,
  required String password,
}) async {
  state = AuthStatus.loading;

  try {
    await _authService.login(
      LoginRequest(
        email: email,
        password: password,
      ),
    );

    state = AuthStatus.authenticated;
  } catch (e) {
    state = AuthStatus.unauthenticated;
    rethrow;
  }
}

}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);