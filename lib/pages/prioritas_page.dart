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

class PrioritasPage extends StatelessWidget {
  const PrioritasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeluargaProvider>();
    final rank = p.ranking;

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Expanded(
              child: Text('Peringkat kelayakan & prioritas bansos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          PeriodeDropdown(),
        ]),
        const SizedBox(height: 14),
        Panel(
          title: 'Dasar penilaian (maksimal 100 poin)',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 10, runSpacing: 8, children: [
              for (final a in Scoring.aspek)
                Chip(
                  label: Text('${a.$1}: ${a.$2} poin'),
                  backgroundColor: AppColors.primarySoft,
                  side: BorderSide.none,
                ),
            ]),
            const SizedBox(height: 10),
            const Text(
                'Semakin tinggi skor, semakin rendah kemampuan ekonomi keluarga sehingga semakin diprioritaskan.',
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: const [
              StatusTag('Prioritas 1'), Text('skor 75-100 (Sangat Miskin)'),
              StatusTag('Prioritas 2'), Text('55-74 (Miskin)'),
              StatusTag('Prioritas 3'), Text('35-54 (Rentan Miskin)'),
              StatusTag('Tidak prioritas'), Text('0-34 (Tidak Miskin)'),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        Panel(
          title: 'Peringkat keluarga (${rank.length})',
          child: rank.isEmpty
              ? const Text('Belum ada data. Tambahkan keluarga atau muat data contoh di Dashboard.',
                  style: TextStyle(color: AppColors.muted))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('#'), numeric: true),
                      DataColumn(label: Text('Kepala keluarga')),
                      DataColumn(label: Text('Kelurahan')),
                      DataColumn(label: Text('Pendapatan')),
                      DataColumn(label: Text('Skor'), numeric: true),
                      DataColumn(label: Text('Klasifikasi')),
                      DataColumn(label: Text('Prioritas')),
                      DataColumn(label: Text('Status bansos')),
                    ],
                    rows: [
                      for (var i = 0; i < rank.length; i++)
                        DataRow(
                          onSelectChanged: (_) => bukaDetail(context, rank[i].id),
                          cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(Text(rank[i].kepala,
                                style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(rank[i].kelurahan)),
                            DataCell(Text(rupiah(rank[i].pendapatan))),
                            DataCell(Text('${p.skor(rank[i]).total} / 100')),
                            DataCell(StatusTag(p.skor(rank[i]).klasifikasi)),
                            DataCell(StatusTag(p.skor(rank[i]).prioritas)),
                            DataCell(StatusTag(p.statusBansos(rank[i]))),
                          ],
                        ),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }
}
