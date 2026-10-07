const Object _sentinel = Object();

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? phone;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
  });

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '';
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final AppUser? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    AppUser? user,
    Object? error = _sentinel,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      error: identical(error, _sentinel) ? this.error : (error as String?),
    );
  }
}
