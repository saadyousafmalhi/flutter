import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/root_gate.dart'; // <-- decides LoginScreen vs HomeTabs

// Providers
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';

// HTTP implementations
//import 'services/auth_service_http.dart';
import 'services/post_service_http.dart';
import 'services/user_service_http.dart';

// (Optional) fake auth for local dev/tests
import 'services/auth_service_fake.dart';

void main() => runApp(const AppRoot());

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthServiceFake()),
        ), // or AuthServiceHttp()
        ChangeNotifierProvider(create: (_) => PostProvider(PostServiceHttp())),
        ChangeNotifierProvider(create: (_) => UserProvider(UserServiceHttp())),
      ],
      child: MaterialApp(
        title: 'Interview App',
        theme: appTheme(),
        home: const RootGate(), // <-- not HomeTabs directly anymore
      ),
    );
  }
}
