import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../providers/keluarga_provider.dart';
import '../../widgets/status_tag.dart';
import 'aksi.dart';
import 'keluarga_detail.dart';
import 'keluarga_form.dart';

class KeluargaPage extends StatelessWidget {
  const KeluargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeluargaProvider>();
    final data = p.items;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        SizedBox(
          width: 360,
          child: TextField(
            onChanged: p.search,
            decoration: const InputDecoration(
              hintText: 'Cari nama, No. KK, atau kelurahan',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => bukaForm(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Tambah keluarga'),
        ),
      ]),
      const SizedBox(height: 16),
      Expanded(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: data.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      p.query.isEmpty
                          ? 'Belum ada data keluarga.'
                          : 'Tidak ada keluarga yang cocok dengan pencarian.',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    if (p.all.isEmpty)
                      TextButton(
                          onPressed: p.muatContoh, child: const Text('Muat data contoh')),
                  ]),
                )
              : SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 270),
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: const [
                          DataColumn(label: Text('Kepala keluarga')),
                          DataColumn(label: Text('Kelurahan')),
                          DataColumn(label: Text('Pendapatan')),
                          DataColumn(label: Text('Jiwa'), numeric: true),
                          DataColumn(label: Text('Skor'), numeric: true),
                          DataColumn(label: Text('Klasifikasi')),
                          DataColumn(label: Text('Verifikasi')),
                          DataColumn(label: Text('Temuan')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: [
                          for (final k in data)
                            DataRow(
                              onSelectChanged: (_) => bukaDetail(context, k.id),
                              cells: [
                                DataCell(Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(k.kepala,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(k.noKk,
                                        style: const TextStyle(
                                            fontSize: 11, color: AppColors.muted)),
                                  ],
                                )),
                                DataCell(Text(k.kelurahan)),
                                DataCell(Text(rupiah(k.pendapatan))),
                                DataCell(Text('${k.jiwa}')),
                                DataCell(Text('${p.skor(k).total}')),
                                DataCell(StatusTag(p.skor(k).klasifikasi)),
                                DataCell(StatusTag(
                                    k.terverifikasi ? 'Terverifikasi' : 'Belum diverifikasi')),
                                DataCell(p.punyaAnomali(k)
                                    ? const Tooltip(
                                        message: 'Ada anomali',
                                        child: Icon(Icons.warning_amber_rounded,
                                            color: AppColors.danger))
                                    : p.punyaValidasi(k)
                                        ? const Tooltip(
                                            message: 'Perlu validasi',
                                            child: Icon(Icons.info_outline,
                                                color: Color(0xFFB7791F)))
                                        : const Text('-')),
                                DataCell(Row(children: [
                                  IconButton(
                                      tooltip: 'Ubah',
                                      onPressed: () => bukaForm(context, data: k),
                                      icon: const Icon(Icons.edit_outlined, size: 20)),
                                  IconButton(
                                      tooltip: 'Hapus',
                                      onPressed: () => hapusKeluarga(context, k),
                                      icon: const Icon(Icons.delete_outline,
                                          size: 20, color: AppColors.danger)),
                                ])),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
      const SizedBox(height: 10),
      Text('Menampilkan ${data.length} dari ${p.all.length} keluarga. Klik baris untuk melihat detail.',
          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
    ]);
  }
}
