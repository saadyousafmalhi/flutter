import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import 'auth_service.dart';

class AuthServiceHttp extends BaseService implements AuthService {
  AuthServiceHttp({http.Client? client}) : super(client: client);

  @override
  Future<AuthResult> signIn({
    required String username,
    required String password,
  }) async {
    debugPrint('HTTP CALL → AuthServiceHttp.signIn()');
    final res = await client
        .post(
          url('/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 12));

    throwOnError(res);
    final data = decodeJson<Map<String, dynamic>>(res);

    final userId = (data['userId'] ?? data['id'] ?? data['user_id'])
        ?.toString();
    final token = (data['token'] ?? data['accessToken'] ?? data['jwt'])
        ?.toString();
    final expRaw = (data['expiresAt'] ?? data['exp'] ?? data['expires_at']);

    if (userId == null || token == null) {
      throw ApiException(
        statusCode: 500,
        message: 'Invalid login response',
        body: res.body,
      );
    }

    return AuthResult(
      userId: userId,
      token: token,
      expiresAt: expRaw != null ? DateTime.tryParse(expRaw.toString()) : null,
    );
  }

  @override
  Future<void> signOut({required String token}) async {
    debugPrint('HTTP CALL → AuthServiceHttp.signOut()');
    final res = await client
        .post(
          url('/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 12));

    throwOnError(res);
  }
}
