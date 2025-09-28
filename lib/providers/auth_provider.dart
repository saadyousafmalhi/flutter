import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/token_source.dart';
import '../services/base_service.dart' show ApiException;
import 'dart:convert';

class AuthProvider extends ChangeNotifier implements TokenSource {
  final AuthService _service;
  AuthProvider(this._service) {
    debugPrint('AuthProvider created');
  }

  bool _isLoggedIn = false;
  bool _loading = false;
  String? _error;
  String? _userId;
  String? _token;
  DateTime? _expiresAt;
  bool _initialized = false;
  String? _email;

  bool get isLoggedIn => _isLoggedIn;
  bool get loading => _loading;
  String? get error => _error;
  String? get userId => _userId;
  String? get email => _email;
  String get displayName => _email ?? _userId ?? 'User';

  String? _emailFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final map = json.decode(payload) as Map<String, dynamic>;
      return map['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  String? get token => _token;

  Future<void> checkLoginStatus({bool force = false}) async {
    if (_initialized && !force) return;
    _initialized = true;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final persisted = prefs.getBool('isLoggedIn') ?? false;
      // Don't downgrade a live, in-memory login.
      if (!_isLoggedIn) {
        _isLoggedIn = persisted;
        _userId = prefs.getString('userId');
        _token = prefs.getString('token');
        _email ??= (_token != null) ? _emailFromToken(_token!) : null;
        final exp = prefs.getString('expiresAt');
        _expiresAt = exp != null ? DateTime.tryParse(exp) : null;
      }
      // Optional: auto-logout if expired
      if (_isLoggedIn &&
          _expiresAt != null &&
          _expiresAt!.isBefore(DateTime.now())) {
        await logout();
      }
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      _userId = null;
      _token = null;
      _expiresAt = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    // 1) Called
    debugPrint(
      '[AuthProvider] login() start rememberMe=$rememberMe username=$username',
    );

    try {
      // Call your service
      final res = await _service.signIn(username: username, password: password);

      // 2) Success from service
      debugPrint(
        '[AuthProvider] login() success userId=${res.userId} '
        'tokenLen=${res.token.length} expires=${res.expiresAt}',
      );

      // Update in-memory state
      _isLoggedIn = true;
      _userId = res.userId;
      _token = res.token;
      _email = _emailFromToken(_token!);
      _expiresAt = res.expiresAt;

      // Persist only if rememberMe
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', _userId!);
        await prefs.setString('token', _token!);
        if (_expiresAt != null) {
          await prefs.setString('expiresAt', _expiresAt!.toIso8601String());
        } else {
          await prefs.remove('expiresAt');
        }
        debugPrint('[AuthProvider] login() persisted rememberMe=true');
      } else {
        debugPrint('[AuthProvider] login() session-only (rememberMe=false)');
      }

      return true;
    } catch (e) {
      // 3) Error path
      if (e is ApiException && (e.statusCode == 400 || e.statusCode == 401)) {
        _error = 'Invalid email or password';
      } else {
        _error = 'Sign-in failed. Please try again.';
        debugPrint('[AuthProvider] login() ERROR: $e');
      }
      _isLoggedIn = false;
      _userId = null;
      _token = null;
      _expiresAt = null;
      debugPrint('[AuthProvider] login() ERROR: $e');
      return false;
    } finally {
      // 4) Always runs; UI will rebuild from here
      _loading = false;
      notifyListeners();
      debugPrint(
        '[AuthProvider] login() end isLoggedIn=$_isLoggedIn loading=$_loading',
      );
    }
  }

  Future<void> logout() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (_token != null) {
        _service.signOut(token: _token!).catchError((_) {});
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userId');
      await prefs.remove('token');
      await prefs.remove('expiresAt');

      _isLoggedIn = false;
      _userId = null;
      _token = null;
      _expiresAt = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => checkLoginStatus(force: true);
}
