import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<UserProvider>();

    if (p.loading && p.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Users')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (p.error != null && p.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Users')),
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

    final List<User> users = p.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: RefreshIndicator(
        onRefresh: () => p.refresh(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(users[i].name),
            subtitle: Text(users[i].email),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UserDetailScreen(user: users[i]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
