import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testora_flutter_ui/features/auth/data/auth_state.dart';

import '../data/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
});

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  StreamSubscription<AppUser?>? _authSubscription;

  @override
  AuthState build() {
    try {
      final repository = ref.read(authRepositoryProvider);

      _authSubscription = repository.authStateChanges().listen(
        (user) {
          state = AuthState(
            isLoading: false,
            isLoggedIn: user != null,
            user: user,
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          state = const AuthState(
            isLoading: false,
            error: 'Unable to restore your session. Please restart Testora.',
          );
        },
      );
    } catch (error) {
      return AuthState(
        isLoading: false,
        error: 'Authentication is unavailable on this platform: $error',
      );
    }

    ref.onDispose(() {
      _authSubscription?.cancel();
      _authSubscription = null;
    });

    return const AuthState(isLoading: true);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(error: null);

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);

      state = AuthState(
        isLoading: false,
        isLoggedIn: true,
        user: user,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: false,
        error: _errorMessage(error),
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(error: null);

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .register(
            fullName: fullName,
            email: email,
            phone: phone,
            password: password,
          );

      state = AuthState(
        isLoading: false,
        isLoggedIn: true,
        user: user,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: false,
        error: _errorMessage(error),
      );
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    state = state.copyWith(error: null);

    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(email: email);
      return true;
    } catch (error) {
      state = state.copyWith(error: _errorMessage(error));
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
      state = const AuthState();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to sign out. Please try again.',
      );
      rethrow;
    }
  }

  String _errorMessage(Object error) {
    if (error is AuthRepositoryException) return error.message;
    if (error is FirebaseException) return error.message ?? error.toString();
    return error.toString();
  }
}
