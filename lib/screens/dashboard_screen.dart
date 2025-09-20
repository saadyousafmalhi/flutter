import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Kick off loads once; providers have an _initialized guard so this won’t spam.
    Future.microtask(() {
      context.read<PostProvider>().load();
      context.read<UserProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final posts = context.watch<PostProvider>();
    final users = context.watch<UserProvider>();

    final isLoading =
        (posts.loading && !posts.hasData) ||
        (users.loading && users.items.isEmpty);
    final hasError = posts.error != null || users.error != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Builder(
        builder: (_) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (posts.error != null) Text('Posts error: ${posts.error}'),
                  if (users.error != null) Text('Users error: ${users.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      posts.refresh();
                      users.refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Both providers have data
          return ListView(
            children: [
              ListTile(title: Text('Posts: ${posts.items.length}')),
              ListTile(title: Text('Users: ${users.items.length}')),
            ],
          );
        },
      ),
    );
  }
}
