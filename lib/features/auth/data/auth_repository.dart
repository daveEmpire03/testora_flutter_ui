import 'package:testora_flutter_ui/features/auth/data/auth_state.dart';

abstract class AuthRepository {
  Future<AppUser?> loadPersistedUser();
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  AppUser? _cached;

  @override
  Future<AppUser?> loadPersistedUser() async => _cached;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _cached = AppUser(id: 'u_1', email: email, fullName: 'Test User');
    return _cached!;
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _cached = AppUser(
      id: 'u_2',
      email: email,
      fullName: fullName,
      phone: phone,
    );
    return _cached!;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _cached = null;
  }
}
