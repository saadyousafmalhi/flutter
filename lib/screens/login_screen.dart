import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Reusable username field
            CustomTextField(
              controller: usernameController,
              label: "Username",
            ),
            const SizedBox(height: 12),

            // Reusable password field
            CustomTextField(
              controller: passwordController,
              label: "Password",
              obscure: true,
            ),
            const SizedBox(height: 20),

            // Reusable PrimaryButton → Welcome
            PrimaryButton(
              label: "Go to Welcome",
              onPressed: () {
                final username = usernameController.text.trim();
                if (username.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a username")),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WelcomeScreen(username: username),
                  ),
                );      

              },
            ),
            const SizedBox(height: 12),

            // Reusable PrimaryButton → API List
            PrimaryButton(
              label: "Load API List",
              onPressed: () {
                Navigator.pushNamed(context, '/api');
              },
            ),
          ],
        ),
      ),
    );
  }
}
