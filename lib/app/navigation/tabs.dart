import 'package:flutter/material.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/post_list_screen.dart';
import '../../screens/user_list_screen.dart';
import '../../screens/login_screen.dart';
import 'tab_navigator.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _index = 0;
  final _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

 

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // system already popped something

        final nav = _navigatorKeys[_index].currentState!;
        if (nav.canPop()) {
          nav.pop();
        } else {
          // At root of current tab → exit or switch tab
          // Example: SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            TabNavigator(navigatorKey: _navigatorKeys[0], initial: DashboardScreen()),
            TabNavigator(navigatorKey: _navigatorKeys[1], initial: PostListScreen()),
            TabNavigator(navigatorKey: _navigatorKeys[2], initial: UserListScreen()),
            TabNavigator(navigatorKey: _navigatorKeys[3], initial: LoginScreen()),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Posts'),
            NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'Users'),
            NavigationDestination(icon: Icon(Icons.login), label: 'Login'),
          ],
          onDestinationSelected: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
