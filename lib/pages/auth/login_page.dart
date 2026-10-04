import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_layout.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    final err = await context.read<AuthProvider>().login(_email.text.trim(), _pass.text);
    if (mounted) setState(() { _busy = false; _error = err; });
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      headline: 'Data keluarga yang rapi,\nbantuan yang tepat sasaran.',
      subtitle: 'Masuk untuk mengelola data keluarga, penilaian kondisi ekonomi, dan kuota bansos.',
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Masuk ke akun',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pass,
              obscureText: true,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Kata sandi'),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: const Text('Masuk'),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const RegisterPage())),
              child: const Text('Belum punya akun? Daftar di sini'),
            ),
          ],
        ),
      ),
    );
  }
}
