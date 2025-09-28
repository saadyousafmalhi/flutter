import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required this.controller, this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofillHints: const [AutofillHints.password],
      textInputAction: TextInputAction.done,
      obscureText: _obscured,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscured = !_obscured),
          icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
          tooltip: _obscured ? 'Show password' : 'Hide password',
        ),
      ),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Password is required' : null,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
    );
  }
}
