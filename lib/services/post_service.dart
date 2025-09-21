import '../models/post.dart';

abstract class PostService {
  Future<List<Post>> fetchPosts();
}
