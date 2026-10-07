import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testora_flutter_ui/features/auth/data/auth_state.dart';

import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _hydrate();
    return const AuthState(isLoading: true);
  }

  Future<void> _hydrate() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.loadPersistedUser();
    state = AuthState(isLoggedIn: user != null, user: user);
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);
      state = AuthState(isLoggedIn: true, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      state = AuthState(isLoggedIn: true, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState();
  }
}
