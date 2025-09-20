import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app_theme.dart';
import 'app/navigation/tabs.dart';
import 'services/post_service.dart';
import 'services/user_service.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';

void main() => runApp(const AppRoot());

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider(PostService())),
        ChangeNotifierProvider(create: (_) => UserProvider(UserService())),
      ],
      child: MaterialApp(
        title: 'Interview App',
        theme: appTheme(),
        home: const HomeTabs(),
      ),
    );
  }
}
