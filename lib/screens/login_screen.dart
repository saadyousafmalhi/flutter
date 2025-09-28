import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import '../widgets/brand_header.dart';
import '../widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      rememberMe: _rememberMe,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
    // RootGate will rebuild automatically via Provider and show HomeTabs.
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, _) => SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 28),
                      const BrandHeader(subtitle: 'Sign in to focus your day'),
                      const SizedBox(height: 24),

                      Card(
                        color: scheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          child: Form(
                            key: _formKey,
                            child: AutofillGroup(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _usernameCtrl,
                                    autofillHints: const [
                                      AutofillHints.username,
                                      AutofillHints.email,
                                    ],
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Username is required'
                                        : null,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context).nextFocus(),
                                  ),
                                  const SizedBox(height: 12),

                                  PasswordField(
                                    controller: _passwordCtrl,
                                    onSubmitted: () {
                                      if (!loading) _handleLogin();
                                    },
                                  ),

                                  const SizedBox(height: 4),
                                  CheckboxListTile(
                                    value: _rememberMe,
                                    onChanged: (v) =>
                                        setState(() => _rememberMe = v ?? true),
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Remember me'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: loading ? null : () {},
                                        child: const Text('Forgot password?'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  FilledButton(
                                    onPressed: loading ? null : _handleLogin,
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48),
                                    ),
                                    child: loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Continue'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'By continuing you agree to our Terms & Privacy',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
