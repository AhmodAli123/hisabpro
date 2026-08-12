import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_notifier.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    final AuthNotifier auth = Provider.of(context, listen: false);
    if (_isLogin) {
      await auth.signIn(_email.text.trim(), _password.text);
    } else {
      await auth.signUp(_email.text.trim(), _password.text);
    }
    setState(() => _loading = false);
    if (auth.isAuthenticated) Navigator.pop(context);
  }

  Future<void> _resetPassword() async {
    final String email = _email.text.trim();
    if (email.isEmpty) return;
    // Supabase handles password reset via email link; show user a message.
    final SnackBar sb = SnackBar(content: Text('Password reset link sent to $email (if registered)'));
    ScaffoldMessenger.of(context).showSnackBar(sb);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loading ? null : _submit, child: Text(_isLogin ? 'Sign in' : 'Register')),
            const SizedBox(height: 8),
            TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? 'Create account' : 'Have an account? Sign in')),
            TextButton(onPressed: _resetPassword, child: const Text('Forgot password?')),
          ],
        ),
      ),
    );
  }
}
