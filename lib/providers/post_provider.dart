import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _service;
  PostProvider(this._service) {
    debugPrint('PostProvider created');
  }

  List<Post> _items = [];
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  List<Post> get items => _items;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasData => _items.isNotEmpty;

  Future<void> load({bool force = false}) async {
    if (_initialized && !force) return;
    _initialized = true;
    _loading = true;
    _error = null;
    notifyListeners();

    debugPrint('Fetching posts... force=$force, initialized=$_initialized');

    try {
      _items = await _service.fetchPosts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);
}
