import 'package:firebase_auth/firebase_auth.dart';
import 'package:testora_flutter_ui/features/auth/data/auth_state.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser> login({required String email, required String password});

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> logout();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AppUser?> authStateChanges() {
    // Keep the app session synchronized when Firebase refreshes the ID token.
    return _firebaseAuth.idTokenChanges().map(_mapFirebaseUser);
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw const AuthRepositoryException(
          'Firebase did not return a signed-in user. Please try again.',
        );
      }

      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(_messageFor(error));
    }
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw const AuthRepositoryException(
          'Firebase did not create an account. Please try again.',
        );
      }

      await user.updateDisplayName(fullName.trim());
      await user.reload();

      final refreshedUser = _firebaseAuth.currentUser ?? user;
      return _mapFirebaseUser(
        refreshedUser,
        fallbackName: fullName.trim(),
      )!;
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(_messageFor(error));
    }
    // Firebase Email/Password Auth cannot store an unverified phone number.
    // The Cloudflare profile API will persist the submitted phone in a later phase.
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      // Avoid disclosing whether an email address has a Testora account.
      if (error.code == 'user-not-found') return;
      throw AuthRepositoryException(_messageFor(error));
    }
  }

  @override
  Future<void> logout() => _firebaseAuth.signOut();

  static AppUser? _mapFirebaseUser(
    User? user, {
    String? fallbackName,
  }) {
    if (user == null) return null;

    final email = user.email ?? '';
    final displayName = user.displayName?.trim();
    final resolvedName =
        (displayName != null && displayName.isNotEmpty)
            ? displayName
            : (fallbackName?.isNotEmpty == true
                ? fallbackName!
                : (email.contains('@') ? email.split('@').first : 'Student'));

    return AppUser(
      id: user.uid,
      email: email,
      fullName: resolvedName,
      phone: user.phoneNumber,
    );
  }

  static String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Sign in instead.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email address or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'A network error occurred. Check your connection and try again.';
      case 'operation-not-allowed':
        return 'Email and password sign-in is not enabled in Firebase Console.';
      case 'requires-recent-login':
        return 'Please sign in again before retrying this action.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
