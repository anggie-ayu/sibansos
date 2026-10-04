import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _form = GlobalKey<FormState>();
  late final Map<String, dynamic> _u = context.read<AuthProvider>().current!;
  late final _nama = TextEditingController(text: _u['nama']);
  late final _kel = TextEditingController(text: _u['kelurahan']);

  Future<void> _simpan() async {
    if (!_form.currentState!.validate()) return;
    await context.read<AuthProvider>().updateProfile(_nama.text.trim(), _kel.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
    }
  }

  BoxDecoration get _card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      );

  @override
  Widget build(BuildContext context) {
    final nama = (_u['nama'] ?? '') as String;
    return SingleChildScrollView(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 260,
          padding: const EdgeInsets.all(24),
          decoration: _card,
          child: Column(children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primarySoft,
              child: Text(nama.isEmpty ? '?' : nama[0].toUpperCase(),
                  style: const TextStyle(
                      fontSize: 28,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            Text(nama, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(_u['peran'] ?? 'Petugas lapangan',
                style: const TextStyle(color: AppColors.muted)),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: _card,
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Informasi akun',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nama,
                  decoration: const InputDecoration(labelText: 'Nama lengkap'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _u['email'],
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _u['nip'],
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'NIP / ID petugas'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _kel,
                  decoration: const InputDecoration(labelText: 'Kelurahan'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Kelurahan wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                FilledButton(onPressed: _simpan, child: const Text('Simpan perubahan')),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
