import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_theme.dart';
import 'app/root_gate.dart'; // <-- decides LoginScreen vs HomeTabs
import 'app/root_scaffold_messenger.dart';

// Providers
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';
import 'providers/task_provider.dart';

// Services (concrete classes, matching your pattern)
import 'services/post_service_http.dart';
import 'services/user_service_http.dart';
import 'services/task_service_http.dart';
import 'services/supabase_auth_http.dart';
import 'services/local_task_store.dart';
import 'services/sync_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create LocalTaskStore once and pass it down.
  final sp = await SharedPreferences.getInstance();
  final store = LocalTaskStore(sp);

  runApp(AppRoot(store: store));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.store});
  final LocalTaskStore store;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Make store available app-wide.
        Provider<LocalTaskStore>.value(value: store),

        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(SupabaseAuthHttp())..checkLoginStatus(),
        ),
        ChangeNotifierProvider(create: (_) => PostProvider(PostServiceHttp())),
        ChangeNotifierProvider(create: (_) => UserProvider(UserServiceHttp())),

        // TaskProvider: keep using the concrete TaskServiceHttp (your existing style).
        ChangeNotifierProvider(
          create: (ctx) {
            final auth = ctx.read<AuthProvider>();
            final store = ctx.read<LocalTaskStore>();
            final taskService = TaskServiceHttp(tokens: auth);

            final sync = SyncManager(
              taskService: taskService,
              auth: auth,
              store: store,
            );

            final taskProv = TaskProvider(
              taskService,
              store,
            ); // ✅ store required
            taskProv.attachSync(sync);
            return taskProv;
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
