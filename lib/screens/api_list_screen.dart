// lib/api_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
class ApiListScreen extends StatefulWidget {
  const ApiListScreen({super.key});

  @override
  State<ApiListScreen> createState() => _ApiListScreenState();
}

class _ApiListScreenState extends State<ApiListScreen> {
  late Future<List<User>> _futureUsers; // stored future

  @override
  void initState() {
    super.initState();
    _futureUsers = fetchUsers(); // load once when screen is created
  }

  Future<List<User>> fetchUsers() async {
    final res = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load users (${res.statusCode})');
    }
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users (pull to refresh)')),
      body: FutureBuilder<List<User>>(
        future: _futureUsers,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${snap.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _futureUsers = fetchUsers());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final users = snap.data ?? const <User>[];
          if (users.isEmpty) {
            // Still allow pull-to-refresh when list is empty:
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _futureUsers = fetchUsers());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No users found')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Reassign the future (triggers FutureBuilder to fetch again)
              setState(() => _futureUsers = fetchUsers());
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(), // enables pull even if few items
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final u = users[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${u.id}')),
                  title: Text(u.name),
                  subtitle: Text(u.email),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


