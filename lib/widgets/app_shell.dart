import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../pages/dashboard_page.dart';
import '../pages/keluarga/keluarga_page.dart';
import '../pages/prioritas_page.dart';
import '../pages/profil_page.dart';
import '../pages/validasi_page.dart';
import '../providers/auth_provider.dart';

/// Kerangka setelah login: sidebar + topbar + isi halaman.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;

  static const _menu = [
    ('Dashboard', Icons.dashboard_outlined),
    ('Data Keluarga', Icons.groups_outlined),
    ('Scoring & Prioritas', Icons.leaderboard_outlined),
    ('Validasi & Anomali', Icons.fact_check_outlined),
    ('Profil', Icons.person_outline),
  ];

  Widget _page() => switch (_idx) {
        0 => DashboardPage(onGo: (i) => setState(() => _idx = i)),
        1 => const KeluargaPage(),
        2 => const PrioritasPage(),
        3 => const ValidasiPage(),
        _ => const ProfilPage(),
      };

  Widget _item(String label, IconData icon, bool on, VoidCallback tap) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Material(
          color: on ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: tap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Icon(icon, size: 18, color: on ? AppColors.primary : const Color(0xFFD6EBE5)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                          color: on ? AppColors.primary : const Color(0xFFD6EBE5))),
                ),
              ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().current!;
    final nama = (user['nama'] ?? '') as String;
    final inisial = nama.isEmpty ? '?' : nama.trim()[0].toUpperCase();

    return Scaffold(
      body: Row(children: [
        Container(
          width: 220,
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 16),
              child: Text('SiBansos',
                  style: TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            for (var i = 0; i < _menu.length; i++)
              _item(_menu[i].$1, _menu[i].$2, _idx == i, () => setState(() => _idx = i)),
            const Spacer(),
            _item('Keluar', Icons.logout, false, () => context.read<AuthProvider>().logout()),
          ]),
        ),
        Expanded(
          child: Column(children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(children: [
                Text(_menu[_idx].$1,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(nama, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(inisial,
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
            Expanded(
              child: Padding(padding: const EdgeInsets.all(24), child: _page()),
            ),
          ]),
        ),
      ]),
    );
  }
}
