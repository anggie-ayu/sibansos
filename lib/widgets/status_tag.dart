import 'package:flutter/material.dart';

class StatusTag extends StatelessWidget {
  final String text;
  const StatusTag(this.text, {super.key});

  static const _merah = (Color(0xFFF9E3E0), Color(0xFFB3372F));
  static const _kuning = (Color(0xFFFBF0D9), Color(0xFFB7791F));
  static const _biru = (Color(0xFFE3F1ED), Color(0xFF0F5C50));
  static const _hijau = (Color(0xFFE2F2E8), Color(0xFF2F7D4F));
  static const _abu = (Color(0xFFEEF0EE), Color(0xFF5E6B66));

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (text) {
      'Sangat Miskin' || 'Prioritas 1' || 'Anomali' || 'Tunda - cek anomali' => _merah,
      'Miskin' || 'Prioritas 2' || 'Perlu validasi' || 'Belum diverifikasi' || 'Menunggu verifikasi' => _kuning,
      'Rentan Miskin' || 'Prioritas 3' => _biru,
      'Tidak Miskin' || 'Tidak prioritas' || 'Terverifikasi' || 'Layak menerima' => _hijau,
      _ => _abu,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
