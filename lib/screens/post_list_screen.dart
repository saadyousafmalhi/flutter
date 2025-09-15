import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'post_detail_screen.dart';

class PostListScreen extends StatelessWidget {
  PostListScreen({super.key});
  final _service = PostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: FutureBuilder<List<Post>>(
        future: _service.fetchPosts(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(
              message: snap.error.toString(),
              onRetry: () => (context as Element).markNeedsBuild(),
            );
          }
          final posts = snap.data ?? const <Post>[];
          if (posts.isEmpty) return const _EmptyView();
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(posts[i].title),
              subtitle: Text(posts[i].body),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: posts[i]),
                  ),
                );  
              },
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Error: $message', textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => const Center(child: Text('No data'));
}
