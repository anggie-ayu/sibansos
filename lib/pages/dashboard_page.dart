import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/format.dart';
import '../core/scoring.dart';
import '../core/theme.dart';
import '../providers/keluarga_provider.dart';
import '../widgets/panel.dart';
import '../widgets/periode_dropdown.dart';
import '../widgets/status_tag.dart';
import 'keluarga/keluarga_detail.dart';

class DashboardPage extends StatelessWidget {
  final void Function(int) onGo;
  const DashboardPage({super.key, required this.onGo});

  List<Widget> _gaps(List<Widget> w, double g) => [
        for (var i = 0; i < w.length; i++) ...[if (i > 0) SizedBox(width: g), w[i]]
      ];

  Widget _kpi(String label, String value, String sub, {Color? warna, VoidCallback? onTap}) =>
      Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w700, color: warna ?? AppColors.ink)),
              Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeluargaProvider>();
    if (p.all.isEmpty) {
      return Center(
        child: Panel(
          title: 'Belum ada data',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tambahkan keluarga lewat menu Data Keluarga, atau muat data contoh\n'
                'untuk melihat dashboard, scoring, dan deteksi anomali bekerja.'),
            const SizedBox(height: 14),
            Row(children: [
              FilledButton(onPressed: p.muatContoh, child: const Text('Muat data contoh')),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () => onGo(1), child: const Text('Ke Data Keluarga')),
            ]),
          ]),
        ),
      );
    }

    final data = p.inPeriode;
    final nBelum = data.where((k) => !k.terverifikasi).length;
    final nAnom = data.where(p.punyaAnomali).length;
    final rata = data.isEmpty
        ? 0.0
        : data.map((k) => p.skor(k).total).reduce((a, b) => a + b) / data.length;
    final n1 = data.where((k) => p.skor(k).total >= Scoring.batasSangatMiskin).length;
    final rekap = p.rekap;
    const klas = ['Sangat Miskin', 'Miskin', 'Rentan Miskin', 'Tidak Miskin'];
    final jumlah = {for (final c in klas) c: data.where((k) => p.skor(k).klasifikasi == c).length};
    final top = p.ranking.take(5).toList();

    int sum(int Function(RekapKelurahan) f) => rekap.fold(0, (s, r) => s + f(r));

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
              child: Text('Ringkasan data keluarga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          const PeriodeDropdown(),
        ]),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _gaps([
            _kpi('Total keluarga', '${data.length}', periodeLabel(p.periodeAktif)),
            _kpi('Perlu diverifikasi', '$nBelum', 'belum terverifikasi',
                warna: const Color(0xFFB7791F), onTap: () => onGo(3)),
            _kpi('Anomali terdeteksi', '$nAnom', 'keluarga ditandai',
                warna: AppColors.danger, onTap: () => onGo(3)),
            _kpi('Rata-rata skor', rata.toStringAsFixed(1), 'dari 100 poin'),
            _kpi('Prioritas 1', '$n1', 'skor ${Scoring.batasSangatMiskin}+',
                onTap: () => onGo(2)),
          ], 12),
        ),
        const SizedBox(height: 16),
        Panel(
          title: 'Rekapitulasi per desa / kelurahan',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Kelurahan')),
                DataColumn(label: Text('Total'), numeric: true),
                DataColumn(label: Text('Sangat Miskin'), numeric: true),
                DataColumn(label: Text('Miskin'), numeric: true),
                DataColumn(label: Text('Rentan'), numeric: true),
                DataColumn(label: Text('Tidak Miskin'), numeric: true),
                DataColumn(label: Text('Perlu verifikasi'), numeric: true),
                DataColumn(label: Text('Rata-rata skor'), numeric: true),
              ],
              rows: [
                for (final r in rekap)
                  DataRow(cells: [
                    DataCell(Text(r.nama)),
                    DataCell(Text('${r.total}')),
                    DataCell(Text('${r.sangat}')),
                    DataCell(Text('${r.miskin}')),
                    DataCell(Text('${r.rentan}')),
                    DataCell(Text('${r.tidak}')),
                    DataCell(Text('${r.verif}')),
                    DataCell(Text(r.rata.toStringAsFixed(1))),
                  ]),
                DataRow(cells: [
                  const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.w700))),
                  for (final v in [
                    sum((r) => r.total), sum((r) => r.sangat), sum((r) => r.miskin),
                    sum((r) => r.rentan), sum((r) => r.tidak), sum((r) => r.verif),
                  ])
                    DataCell(Text('$v', style: const TextStyle(fontWeight: FontWeight.w700))),
                  DataCell(Text(rata.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w700))),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 2,
            child: Panel(
              title: 'Sebaran klasifikasi',
              child: Column(children: [
                for (final c in klas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(children: [
                      Row(children: [
                        StatusTag(c),
                        const Spacer(),
                        Text('${jumlah[c]} keluarga',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: data.isEmpty ? 0 : jumlah[c]! / data.length,
                          minHeight: 8,
                          backgroundColor: AppColors.line,
                          color: AppColors.primary,
                        ),
                      ),
                    ]),
                  ),
              ]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Panel(
              title: 'Keluarga paling diprioritaskan',
              trailing: TextButton(
                  onPressed: () => onGo(2), child: const Text('Lihat semua')),
              child: Column(children: [
                for (var i = 0; i < top.length; i++)
                  InkWell(
                    onTap: () => bukaDetail(context, top[i].id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        SizedBox(
                            width: 28,
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, color: AppColors.muted))),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(top[i].kepala,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(top[i].kelurahan,
                                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                          ]),
                        ),
                        Text('${p.skor(top[i]).total}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(width: 12),
                        StatusTag(p.skor(top[i]).prioritas),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}
