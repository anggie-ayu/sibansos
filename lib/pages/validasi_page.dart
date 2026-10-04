import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/anomali.dart';
import '../core/theme.dart';
import '../models/keluarga.dart';
import '../providers/keluarga_provider.dart';
import '../widgets/panel.dart';
import '../widgets/periode_dropdown.dart';
import '../widgets/status_tag.dart';
import 'keluarga/aksi.dart';
import 'keluarga/keluarga_detail.dart';

class ValidasiPage extends StatefulWidget {
  const ValidasiPage({super.key});
  @override
  State<ValidasiPage> createState() => _ValidasiPageState();
}

class _ValidasiPageState extends State<ValidasiPage> {
  String _f = 'semua';

  Widget _kpi(String l, int v, Color c) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            Text('$v', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: c)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeluargaProvider>();
    final data = p.inPeriode;
    final nAnom = data.where(p.punyaAnomali).length;
    final nVal = data.where(p.punyaValidasi).length;
    final nBelum = data.where((k) => !k.terverifikasi).length;

    bool cocok(Keluarga k) => switch (_f) {
          'anomali' => p.punyaAnomali(k),
          'validasi' => p.punyaValidasi(k),
          'belum' => !k.terverifikasi,
          _ => p.temuanOf(k.id).isNotEmpty || !k.terverifikasi,
        };
    int bobot(Keluarga k) => (p.punyaAnomali(k) ? 2 : 0) + (!k.terverifikasi ? 1 : 0);
    final list = data.where(cocok).toList()..sort((a, b) => bobot(b).compareTo(bobot(a)));

    const filter = [
      ('semua', 'Semua'), ('anomali', 'Anomali'), ('validasi', 'Perlu validasi'),
      ('belum', 'Belum diverifikasi'),
    ];

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Expanded(
              child: Text('Validasi data & deteksi anomali',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          PeriodeDropdown(),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _kpi('Keluarga dengan anomali', nAnom, AppColors.danger),
          const SizedBox(width: 12),
          _kpi('Perlu validasi data', nVal, const Color(0xFFB7791F)),
          const SizedBox(width: 12),
          _kpi('Belum diverifikasi', nBelum, AppColors.ink),
        ]),
        const SizedBox(height: 14),
        Wrap(spacing: 8, children: [
          for (final f in filter)
            ChoiceChip(
              label: Text(f.$2),
              selected: _f == f.$1,
              onSelected: (_) => setState(() => _f = f.$1),
            ),
        ]),
        const SizedBox(height: 14),
        if (list.isEmpty)
          const Panel(child: Text('Tidak ada data pada filter ini.', style: TextStyle(color: AppColors.muted))),
        for (final k in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text('${k.kepala}  -  ${k.kelurahan}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  StatusTag(k.terverifikasi ? 'Terverifikasi' : 'Belum diverifikasi'),
                ]),
                const SizedBox(height: 8),
                if (p.temuanOf(k.id).isEmpty)
                  const Text('Tidak ada temuan. Data siap diverifikasi.',
                      style: TextStyle(color: AppColors.muted))
                else
                  for (final Temuan t in p.temuanOf(k.id))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        Icon(t.anomali ? Icons.warning_amber_rounded : Icons.info_outline,
                            size: 18,
                            color: t.anomali ? AppColors.danger : const Color(0xFFB7791F)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(t.pesan)),
                      ]),
                    ),
                const SizedBox(height: 10),
                Row(children: [
                  OutlinedButton(
                      onPressed: () => bukaDetail(context, k.id),
                      child: const Text('Lihat detail')),
                  const SizedBox(width: 8),
                  FilledButton(
                      onPressed: () => ubahVerifikasi(context, k),
                      child: Text(k.terverifikasi ? 'Batalkan verifikasi' : 'Tandai terverifikasi')),
                ]),
              ]),
            ),
          ),
      ]),
    );
  }
}
