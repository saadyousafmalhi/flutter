import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  final _posts = PostService().fetchPosts();
  final _users = UserService().fetchUsers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_posts, _users]),
        builder: (context, snap) {
          if (!snap.hasData) {
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          final posts = snap.data![0] as List<Post>;
          final users = snap.data![1] as List<User>;
          return ListView(
            children: [
              ListTile(title: Text('Posts: ${posts.length}')),
              ListTile(title: Text('Users: ${users.length}')),
            ],
          );
        },
      ),
    );
  }
}
