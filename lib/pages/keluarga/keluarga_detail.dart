import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/format.dart';
import '../../core/scoring.dart';
import '../../core/theme.dart';
import '../../models/keluarga.dart';
import '../../providers/keluarga_provider.dart';
import '../../widgets/panel.dart';
import '../../widgets/score_bar.dart';
import '../../widgets/status_tag.dart';
import 'aksi.dart';
import 'keluarga_form.dart';

void bukaDetail(BuildContext c, String id) => Navigator.push(
    c, MaterialPageRoute(builder: (_) => KeluargaDetailPage(id: id)));

class KeluargaDetailPage extends StatelessWidget {
  final String id;
  const KeluargaDetailPage({super.key, required this.id});

  Widget _info(String l, Widget v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 150, child: Text(l, style: const TextStyle(color: AppColors.muted))),
          Expanded(child: v),
        ]),
      );

  Widget _t(String s) => Text(s, style: const TextStyle(fontWeight: FontWeight.w500));

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeluargaProvider>();
    final k = p.byId(id);
    if (k == null) {
      return Scaffold(
          appBar: AppBar(), body: const Center(child: Text('Data keluarga tidak ditemukan')));
    }
    final s = Scoring.hitung(k);
    final temuan = p.temuanOf(k.id);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('Detail keluarga')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Panel(
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Keluarga ${k.kepala}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('No. KK ${k.noKk}  |  ${k.kelurahan}, RT/RW ${k.rtRw}',
                        style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      StatusTag(s.klasifikasi),
                      StatusTag(s.prioritas),
                      StatusTag(k.terverifikasi ? 'Terverifikasi' : 'Belum diverifikasi'),
                      StatusTag(p.statusBansos(k)),
                    ]),
                  ]),
                ),
                Column(children: [
                  Text('${s.total}',
                      style: const TextStyle(
                          fontSize: 44, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const Text('dari 100 poin', style: TextStyle(color: AppColors.muted)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 3,
                child: Panel(
                  title: 'Informasi keluarga',
                  child: Column(children: [
                    _info('NIK kepala keluarga', _t(k.nikKepala)),
                    _info('Alamat', _t(k.alamat)),
                    _info('Pendapatan bulanan', _t(rupiah(k.pendapatan))),
                    _info('Jumlah tanggungan', _t('${k.tanggungan} orang')),
                    _info('Status pekerjaan', _t(k.pekerjaan)),
                    _info('Kondisi rumah', _t(k.rumah)),
                    _info('Aset & harta', _t(k.aset.isEmpty ? 'Tidak ada' : k.aset.join(', '))),
                    _info('Tanggal update', _t(tanggal(k.tanggalUpdate))),
                  ]),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: Panel(
                  title: 'Rincian skor',
                  child: Column(children: [
                    for (final c in s.komponen) ScoreBar(c.nama, c.nilai, c.maks),
                    const Divider(),
                    Row(children: [
                      const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))),
                      Text('${s.total} / 100', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Panel(
              title: 'Anggota keluarga (${k.jiwa} jiwa)',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('NIK')),
                    DataColumn(label: Text('Hubungan')),
                    DataColumn(label: Text('Usia')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text(k.kepala)),
                      DataCell(Text(k.nikKepala)),
                      const DataCell(StatusTag('Prioritas 3')), // placeholder diganti di bawah
                      const DataCell(Text('-')),
                    ]),
                    for (final a in k.anggota)
                      DataRow(cells: [
                        DataCell(Text(a.nama)),
                        DataCell(Text(a.nik)),
                        DataCell(Text(a.hubungan)),
                        DataCell(Text('${a.usia}')),
                      ]),
                  ]..first = DataRow(cells: [
                      DataCell(Text(k.kepala)),
                      DataCell(Text(k.nikKepala)),
                      const DataCell(Text('Kepala keluarga',
                          style: TextStyle(fontWeight: FontWeight.w600))),
                      const DataCell(Text('-')),
                    ]),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Panel(
              title: 'Hasil validasi & deteksi anomali',
              child: temuan.isEmpty
                  ? const Row(children: [
                      Icon(Icons.check_circle_outline, color: Color(0xFF2F7D4F)),
                      SizedBox(width: 8),
                      Text('Tidak ada anomali maupun masalah validasi.'),
                    ])
                  : Column(children: [
                      for (final t in temuan)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(children: [
                            Icon(t.anomali ? Icons.warning_amber_rounded : Icons.info_outline,
                                color: t.anomali ? AppColors.danger : const Color(0xFFB7791F)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(t.pesan)),
                            StatusTag(t.anomali ? 'Anomali' : 'Perlu validasi'),
                          ]),
                        ),
                    ]),
            ),
            const SizedBox(height: 18),
            Row(children: [
              FilledButton.icon(
                onPressed: () => bukaForm(context, data: k),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Ubah data'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => ubahVerifikasi(context, k),
                icon: Icon(k.terverifikasi ? Icons.undo : Icons.verified_outlined, size: 18),
                label: Text(k.terverifikasi ? 'Batalkan verifikasi' : 'Tandai terverifikasi'),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                onPressed: () async {
                  final nav = Navigator.of(context);
                  if (await hapusKeluarga(context, k)) nav.pop();
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus'),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
