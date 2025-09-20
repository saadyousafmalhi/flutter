import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service;
  UserProvider(this._service);

  List<User> _items = [];
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  List<User> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({bool force = false}) async {
    if (_initialized && !force) return;
    _initialized = true;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.fetchUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);
}
