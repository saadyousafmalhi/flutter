// lib/services/local_auth_store.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthStore {
  static const _kToken = 'sb.access_token';

  Future<String?> read() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  Future<void> write(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
  }
}
