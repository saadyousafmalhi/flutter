import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_theme.dart';
import 'app/root_gate.dart'; // <-- decides LoginScreen vs HomeTabs
import 'app/root_scaffold_messenger.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';
import 'providers/task_provider.dart';

// HTTP implementations
//import 'services/auth_service_http.dart';
import 'services/post_service_http.dart';
import 'services/user_service_http.dart';
import 'services/task_service_http.dart';
import 'services/supabase_auth_http.dart';

// (Optional) fake auth for local dev/tests
//import 'services/auth_service_fake.dart';

void main() => runApp(const AppRoot());

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(SupabaseAuthHttp())..checkLoginStatus(),
        ),
        ChangeNotifierProvider(create: (_) => PostProvider(PostServiceHttp())),
        ChangeNotifierProvider(create: (_) => UserProvider(UserServiceHttp())),
        ChangeNotifierProvider(
          create: (ctx) {
            final auth = ctx.read<AuthProvider>(); // TokenSource
            return TaskProvider(
              TaskServiceHttp(tokens: auth), // reads token via getter
              // LocalTaskStore(), // include if your provider expects it
            );
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, theme, __) => MaterialApp(
          title: 'Interview App',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          theme: appTheme(),
          darkTheme: appDarkTheme(),
          themeMode: theme.mode,
          home: const RootGate(),
        ),
      ),
    );
  }
}
