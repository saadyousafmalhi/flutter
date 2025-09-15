import 'package:http/http.dart' as http;
import 'base_service.dart';
import '../models/post.dart';

class PostService extends BaseService {
  PostService({http.Client? client}) : super(client: client);

  Future<List<Post>> fetchPosts() async {
    final res = await client
        .get(url('/posts'))
        .timeout(const Duration(seconds: 12));
    throwOnError(res);
    final data = decodeJson<List>(res);
    return data.map((e) => Post.fromJson(e)).toList();
  }
}
