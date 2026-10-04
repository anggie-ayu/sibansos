import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_layout.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _nip = TextEditingController();
  final _email = TextEditingController();
  final _kel = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  String? _error;

  String? _wajib(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final err = await context.read<AuthProvider>().register({
      'nama': _nama.text.trim(),
      'nip': _nip.text.trim(),
      'email': _email.text.trim(),
      'kelurahan': _kel.text.trim(),
      'password': _pass.text,
    });
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Akun dibuat. Silakan masuk.')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (final c in [_nama, _nip, _email, _kel, _pass, _pass2]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 12);
    return AuthLayout(
      headline: 'Buat akun petugas.',
      subtitle: 'Isi data berikut untuk mulai mengelola data keluarga di kelurahanmu.',
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Daftar akun baru',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama lengkap'),
                validator: (v) => _wajib(v, 'Nama')),
            gap,
            TextFormField(
                controller: _nip,
                decoration: const InputDecoration(labelText: 'NIP / ID petugas'),
                validator: (v) => _wajib(v, 'NIP')),
            gap,
            TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null),
            gap,
            TextFormField(
                controller: _kel,
                decoration: const InputDecoration(labelText: 'Kelurahan'),
                validator: (v) => _wajib(v, 'Kelurahan')),
            gap,
            TextFormField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata sandi'),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Minimal 6 karakter' : null),
            gap,
            TextFormField(
                controller: _pass2,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Ulangi kata sandi'),
                validator: (v) => v != _pass.text ? 'Kata sandi tidak sama' : null),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ),
            const SizedBox(height: 18),
            FilledButton(onPressed: _submit, child: const Text('Buat akun')),
            const SizedBox(height: 6),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Sudah punya akun? Masuk')),
          ],
        ),
      ),
    );
  }
}
