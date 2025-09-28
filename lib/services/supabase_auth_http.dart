// lib/services/supabase_auth_http.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'base_service.dart';
import '../config/supabase_config.dart';
import 'auth_service.dart'; // abstract: AuthService + AuthResult

class SupabaseAuthHttp extends BaseService implements AuthService {
  SupabaseAuthHttp({http.Client? client})
    : super(client: client, base: kSupabaseAuthUrl);

  // Add project apikey; keeps Accept/User-Agent from BaseService.
  @override
  Map<String, String> get defaultHeaders => {
    ...super.defaultHeaders,
    'apikey': kSupabaseAnonKey,
  };

  /// AuthService API used by AuthProvider (email/password)
  @override
  Future<AuthResult> signIn({
    required String username, // email
    required String password,
  }) async {
    debugPrint('HTTP CALL → SupabaseAuthHttp.signIn()');

    final res = await post(
      url('/token', query: {'grant_type': 'password'}),
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'email': username, 'password': password}),
    ).timeout(const Duration(seconds: 12));

    throwOnError(res);

    final map = decodeJson<Map<String, dynamic>>(res);
    final token = map['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException(
        statusCode: 500,
        message: 'No access_token in response',
        body: res.body,
      );
    }

    final expiresIn = (map['expires_in'] as num?)?.toInt();
    final expiresAt = expiresIn == null
        ? null
        : DateTime.now().add(Duration(seconds: expiresIn));

    String userId = '';
    final userMap = map['user'];
    if (userMap is Map<String, dynamic>) {
      final id = userMap['id'];
      if (id is String) userId = id;
    }

    return AuthResult(userId: userId, token: token, expiresAt: expiresAt);
  }

  /// Optional convenience if you need just the token elsewhere.
  Future<String> signInWithPassword(String email, String password) async {
    final r = await signIn(username: email, password: password);
    return r.token;
  }

  @override
  Future<void> signOut({required String token}) async {
    // No-op (client clears token); add revoke if you store refresh tokens.
    debugPrint('HTTP CALL → SupabaseAuthHttp.signOut()');
  }
}
