import 'package:flutter/material.dart';

class CheatSheetScreen extends StatelessWidget {
  const CheatSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Interview Cheat Sheet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 0) Fundamentals (C1–C7)
          _Section(
            title: 'Layout & Styling (C1–C7)',
            bullets: const [
              'Widgets compose UI; everything is a widget.',
              'Common layout: Row/Column, Expanded/Flexible, SizedBox, Align.',
              'Spacing: SizedBox / Padding; constraints flow down; sizes go up.',
              'Make static subtrees const to reduce rebuild work.',
            ],
            code: r'''
// Row + Expanded + spacing
Row(
  children: const [
    Expanded(child: Text('Left')),
    SizedBox(width: 12),
    Expanded(child: Text('Right')),
  ],
)
''',
          ),

          // 1) Input & Validation (C4–C6, C8)
          _Section(
            title: 'Forms & Validation (C4–C6, C8)',
            bullets: const [
              'Use Form + GlobalKey<FormState> for grouped validation.',
              'TextEditingController for reading/writing fields.',
              'Obscure text for passwords; show errorText via validator.',
            ],
            code: r'''
final _formKey = GlobalKey<FormState>();
TextFormField(
  controller: userCtrl,
  decoration: const InputDecoration(labelText: 'Username'),
  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
);
''',
          ),

          // 2) Navigation basics (C9 + your RootGate)
          _Section(
            title: 'Navigation Patterns (C9 + Gate)',
            bullets: const [
              'Use a root gate (AuthProvider) to choose Login vs Home.',
              'Per-tab Navigator for independent stacks; PopScope to handle back.',
              'Prefer pushing pages with MaterialPageRoute or typed routes.',
            ],
            code: r'''
// Gate idea (simplified)
Widget build(BuildContext ctx) {
  final auth = ctx.watch<AuthProvider>();
  if (auth.loading) return const CircularProgressIndicator();
  return auth.isLoggedIn ? const HomeTabs() : const LoginScreen();
}
''',
          ),

          // 3) Lists & Async (C10–C12)
          _Section(
            title: 'Lists & Async (C10–C12)',
            bullets: const [
              'ListView.builder for large lists (itemBuilder + itemCount).',
              'FutureBuilder is fine for one-off loads, but app-wide data fits Provider better.',
              'Pull-to-refresh uses RefreshIndicator + provider.refresh().',
            ],
            code: r'''
// Provider-driven list
ListView.builder(
  itemCount: context.watch<PostProvider>().items.length,
  itemBuilder: (_, i) {
    final p = context.read<PostProvider>().items[i];
    return ListTile(title: Text(p.title));
  },
);
''',
          ),

          // 4) Services & Error handling (C11–C13)
          _Section(
            title: 'Services & Errors (C11–C13)',
            bullets: const [
              'Services isolate HTTP & parsing; providers call services.',
              'Throw typed ApiException on non-2xx; providers convert to user-facing error strings.',
              'Timeouts: wrap http calls with .timeout(Duration(seconds: 12)).',
            ],
            code: r'''
// BaseService helpers: url(), decodeJson<T>(), throwOnError(res)
final res = await client.get(url('/posts')).timeout(const Duration(seconds: 12));
throwOnError(res);
''',
          ),

          // 5) Folder structure & reusable widgets (C13–C14)
          _Section(
            title: 'Structure & Reuse (C13–C14)',
            bullets: const [
              'Folders: /screens, /providers, /services, /models, /widgets, /app.',
              'Extract common UI into widgets (PrimaryButton, CustomTextField).',
              'Keep services UI-agnostic for testability.',
            ],
          ),

          // 6) Provider patterns (C15)
          _Section(
            title: 'Provider State Patterns (C15)',
            bullets: const [
              'Expose loading/error/data; update via notifyListeners().',
              'Use an _initialized guard to avoid duplicate fetches.',
              'watch() to rebuild UI; read() for one-off calls; select() for granular rebuilds.',
            ],
            code: r'''
// Granular rebuild with select
final count = context.select<PostProvider, int>((p) => p.items.length);
''',
          ),

          // 7) Tabs, KeepAlive, Back behavior (C15)
          _Section(
            title: 'Tabs & Back Behavior (C15)',
            bullets: const [
              'IndexedStack keeps tab states alive; with AutomaticKeepAliveClientMixin for lists.',
              'Navigator per tab for deep stacks; back pops current tab first.',
            ],
          ),

          // 8) Auth & Persistence (C16)
          _Section(
            title: 'Auth & Persistence (C16)',
            bullets: const [
              'AuthProvider.login() sets state and (optionally) persists to SharedPreferences.',
              'On app start, checkLoginStatus() reads once and updates gate.',
              'Logout clears state + storage; gate flips to Login automatically.',
            ],
            code: r'''
// Remember me (simplified)
if (rememberMe) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('userId', _userId!);
}
''',
          ),

          // 9) Theming (C17)
          _Section(
            title: 'Material 3 Theming (C17)',
            bullets: const [
              'ColorScheme.fromSeed for cohesive palette.',
              'ThemeProvider persists ThemeMode (light/dark/system).',
              'Custom widgets avoid hardcoded colors and rely on themed components.',
            ],
          ),

          // 10) Testing & Debugging (bonus)
          _Section(
            title: 'Testing & Debugging (Bonus)',
            bullets: const [
              'Unit-test services with mock http.Client.',
              'Widget-test providers with ChangeNotifierProvider + pumpWidget.',
              'Use debugPrint sparingly; remove or gate behind kDebugMode.',
            ],
            code: r'''
// Mock client example (pseudo)
final client = MockClient((req) async => Response('[]', 200));
final svc = PostServiceHttp(client: client);
''',
          ),

          // 11) Performance & Keys (bonus)
          _Section(
            title: 'Performance & Keys',
            bullets: const [
              'Use const where possible; prefer builder lists.',
              'Assign Keys when reordering to preserve state.',
              'Avoid heavy work in build(); move to initState or providers.',
            ],
            code: r'''
// KeepAlive on list tab
class MyList extends StatefulWidget { ... }
class _MyListState extends State<MyList> with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;
}
''',
          ),

          // 12) Deployment awareness (C20)
          _Section(
            title: 'Deployment Awareness (C20)',
            bullets: const [
              'Android: release APK/AAB; iOS: archive with Xcode.',
              'Understand signing (keystore / certs) at a high level.',
              'CI/CD: run analyze, tests, build; cache Flutter & Pods for speed.',
            ],
          ),

          // 13) Interview answer templates (C18–C19)
          _Section(
            title: 'Answer Templates (Tie to Your App)',
            bullets: const [
              'State mgmt: “Provider + ChangeNotifier. Screens watch/select only what they need. We cache first load with _initialized and expose refresh().”',
              'Navigation: “RootGate chooses Login vs Home. Each tab owns a Navigator; PopScope handles back.”',
              'Errors: “Services throw ApiException; providers surface error; UI shows SnackBar/retry.”',
              'Auth: “Remember-me via SharedPreferences; guarded startup check; logout flips gate.”',
              'Theming: “M3 + ColorScheme.fromSeed; ThemeProvider for ThemeMode; custom widgets rely on theme.”',
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.bullets = const [], this.code});
  final String title;
  final List<String> bullets;
  final String? code;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.titleLarge),
            const SizedBox(height: 8),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: t.bodyMedium),
                    Expanded(child: Text(b, style: t.bodyMedium)),
                  ],
                ),
              ),
            ),
            if (code != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  code!,
                  style: t.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
