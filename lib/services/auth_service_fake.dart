import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

/// In-memory fake auth for local dev/tests.
/// - By default accepts ANY non-empty username/password.
/// - You can require specific credentials, simulate latency/failures, and set token TTL.
class AuthServiceFake implements AuthService {
  final Duration loginDelay;
  final Duration signOutDelay;
  final Duration tokenTtl;
  final bool requireSpecificCredentials;
  final String validUsername;
  final String validPassword;
  final double failureRate; // 0.0..1.0 chance to throw a fake network error

  final Random _rng = Random();

  AuthServiceFake({
    this.loginDelay = const Duration(milliseconds: 300),
    this.signOutDelay = const Duration(milliseconds: 120),
    this.tokenTtl = const Duration(days: 7),
    this.requireSpecificCredentials = false,
    this.validUsername = 'test',
    this.validPassword = '1234',
    this.failureRate = 0.0,
  });

  @override
  Future<AuthResult> signIn({
    required String username,
    required String password,
  }) async {
    debugPrint('FAKE AUTH → signIn(username: $username)');

    // Simulate network latency
    await Future.delayed(loginDelay);

    // Optional random failure (e.g., flaky network)
    if (failureRate > 0 && _rng.nextDouble() < failureRate) {
      throw Exception('Network error (simulated)');
    }

    // Basic validation
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Invalid credentials');
    }

    // Optional strict check (handy for demos/tests)
    if (requireSpecificCredentials &&
        (username != validUsername || password != validPassword)) {
      throw Exception('Invalid credentials');
    }

    final expiry = DateTime.now().add(tokenTtl);
    final rand = _rng.nextInt(0x7fffffff).toRadixString(36); // < 2^31
    final token =
        'fake-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-$rand';

    return AuthResult(
      userId: username, // echo username as userId for convenience
      token: token,
      expiresAt: expiry,
    );
  }

  @override
  Future<void> signOut({required String token}) async {
    debugPrint('FAKE AUTH → signOut(token: ${token.substring(0, 12)}...)');
    await Future.delayed(signOutDelay);
  }
}
