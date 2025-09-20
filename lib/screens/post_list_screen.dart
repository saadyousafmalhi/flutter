import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import 'post_detail_screen.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Kick off the first load after the first frame
    Future.microtask(() => context.read<PostProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = context.watch<PostProvider>();

    if (p.loading && !p.hasData) {
      return Scaffold(
        appBar: AppBar(title: Text('Posts')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (p.error != null && !p.hasData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: ${p.error}', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => p.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final List<Post> posts = p.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: RefreshIndicator(
        onRefresh: () => p.refresh(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
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
        ),
      ),
    );
  }
}
