import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/keluarga.dart';
import '../../providers/keluarga_provider.dart';

void _snack(BuildContext c, String t) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(t)));

Future<bool> hapusKeluarga(BuildContext context, Keluarga k) async {
  final prov = context.read<KeluargaProvider>();
  final ya = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Hapus data keluarga?'),
      content: Text('Data keluarga ${k.kepala} beserta ${k.anggota.length} anggotanya akan dihapus permanen.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (ya != true) return false;
  await prov.remove(k.id);
  if (context.mounted) _snack(context, 'Data keluarga dihapus');
  return true;
}

Future<void> ubahVerifikasi(BuildContext context, Keluarga k) async {
  final prov = context.read<KeluargaProvider>();
  if (!k.terverifikasi && prov.punyaAnomali(k)) {
    final lanjut = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Masih ada anomali'),
        content: const Text(
            'Data ini memiliki anomali yang belum diperbaiki. Tetap tandai sebagai terverifikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tetap verifikasi')),
        ],
      ),
    );
    if (lanjut != true) return;
  }
  await prov.setVerifikasi(k.id, !k.terverifikasi);
  if (context.mounted) {
    _snack(context, k.terverifikasi ? 'Verifikasi dibatalkan' : 'Data ditandai terverifikasi');
  }
}
