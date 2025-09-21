// lib/app/navigation/tabs.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

// Screens
import '../../screens/dashboard_screen.dart';
import '../../screens/post_list_screen.dart';
import '../../screens/user_list_screen.dart';
import 'tab_navigator.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _index = 0;

  late final List<Widget> _roots = [
    DashboardScreen(),
    PostListScreen(),
    UserListScreen(),
  ];

  late final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    _roots.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  @override
  Widget build(BuildContext context) {
    // Only the AppBar title depends on userId; this avoids rebuilding the whole widget.
    final userId = context.select<AuthProvider, String?>((a) => a.userId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // system already popped something

        final nav = _navigatorKeys[_index].currentState!;
        if (nav.canPop()) {
          nav.pop();
        } else {
          // At root of current tab — you could SystemNavigator.pop() or ignore.
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home${userId != null ? " — $userId" : ""}'),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Theme',
              onSelected: (v) {
                final tp = context.read<ThemeProvider>();
                if (v == 'light') tp.set(ThemeMode.light);
                if (v == 'dark') tp.set(ThemeMode.dark);
                if (v == 'system') tp.set(ThemeMode.system);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'light', child: Text('Light')),
                PopupMenuItem(value: 'dark', child: Text('Dark')),
                PopupMenuItem(value: 'system', child: Text('System (auto)')),
              ],
            ),
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                debugPrint('LOGOUT ICON TAPPED');
                await context.read<AuthProvider>().logout();
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logged out')));
                // RootGate will automatically show LoginScreen after logout.
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: List.generate(
            _roots.length,
            (i) => TabNavigator(
              navigatorKey: _navigatorKeys[i],
              initial: _roots[i],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.article_outlined),
              label: 'Posts',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Users',
            ),
          ],
          onDestinationSelected: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
