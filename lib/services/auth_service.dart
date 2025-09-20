// Defines the contract only (no HTTP here).
class AuthResult {
  final String userId;
  final String token;
  final DateTime? expiresAt;
  const AuthResult({required this.userId, required this.token, this.expiresAt});
}

abstract class AuthService {
  Future<AuthResult> signIn({
    required String username,
    required String password,
  });
  Future<void> signOut({required String token});
}
