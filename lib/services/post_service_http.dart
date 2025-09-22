import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import '../models/post.dart';
import 'post_service.dart';

class PostServiceHttp extends BaseService implements PostService {
  PostServiceHttp({http.Client? client}) : super(client: client);

  @override
  Future<List<Post>> fetchPosts() async {
    debugPrint('HTTP CALL → PostServiceHttp.fetchPosts()');
    final res = await get(url('/posts')).timeout(const Duration(seconds: 12));
    throwOnError(res);
    final data = decodeJson<List>(res);
    return data.map((e) => Post.fromJson(e)).toList();
  }
}
