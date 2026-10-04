import '../models/keluarga.dart';

/// anomali = true  -> data janggal / tidak konsisten (merah)
/// anomali = false -> perlu validasi / dilengkapi (kuning)
class Temuan {
  final String pesan;
  final bool anomali;
  const Temuan(this.pesan, {required this.anomali});
}

class Pemeriksa {
  final Map<String, int> _kk = {};
  final Map<String, int> _nik = {};

  Pemeriksa(List<Keluarga> semua) {
    for (final k in semua) {
      _kk[k.noKk] = (_kk[k.noKk] ?? 0) + 1;
      for (final n in k.semuaNik) {
        _nik[n] = (_nik[n] ?? 0) + 1;
      }
    }
  }

  List<Temuan> periksa(Keluarga k) {
    final t = <Temuan>[];
    final d16 = RegExp(r'^\d{16}$');
    final now = DateTime.now();

    // ---- Validasi kelengkapan & format ----
    if (!d16.hasMatch(k.noKk)) {
      t.add(const Temuan('No. KK bukan 16 digit angka', anomali: false));
    }
    if (k.semuaNik.any((n) => !d16.hasMatch(n))) {
      t.add(const Temuan('Ada NIK yang bukan 16 digit angka', anomali: false));
    }
    if (k.anggota.isEmpty) {
      t.add(const Temuan('Belum ada anggota keluarga yang tercatat', anomali: false));
    }
    final hari = now.difference(k.tanggalUpdate).inDays;
    if (hari > 180) {
      t.add(Temuan('Data belum diperbarui $hari hari (lebih dari 6 bulan)', anomali: false));
    }

    // ---- Deteksi anomali ----
    if ((_kk[k.noKk] ?? 0) > 1) {
      t.add(Temuan('No. KK ${k.noKk} terdaftar pada lebih dari satu keluarga', anomali: true));
    }
    final ganda = k.semuaNik.where((n) => (_nik[n] ?? 0) > 1).toSet();
    if (ganda.isNotEmpty) {
      t.add(Temuan('NIK ganda: ${ganda.length} NIK tercatat lebih dari sekali', anomali: true));
    }
    if (k.tanggalUpdate.isAfter(now.add(const Duration(days: 1)))) {
      t.add(const Temuan('Tanggal update berada di masa depan', anomali: true));
    }

    final rendah = k.pendapatan <= 1500000;
    if (rendah && k.aset.contains(kAset[1])) {
      t.add(const Temuan('Pendapatan rendah tetapi memiliki mobil', anomali: true));
    } else if (rendah && k.aset.length >= 3) {
      t.add(Temuan('Pendapatan rendah tetapi memiliki ${k.aset.length} jenis aset', anomali: true));
    }
    if (k.pendapatan == 0 && k.pekerjaan == kPekerjaan[3]) {
      t.add(const Temuan('Berstatus pegawai/wiraswasta tetap tetapi pendapatan Rp 0', anomali: true));
    }
    if (k.pendapatan >= 5000000 && k.pekerjaan == kPekerjaan[0]) {
      t.add(const Temuan('Pendapatan tinggi tetapi berstatus tidak bekerja', anomali: true));
    }
    if (k.pendapatan >= 5000000 && k.rumah == kRumah[0]) {
      t.add(const Temuan('Pendapatan tinggi tetapi rumah tidak layak huni', anomali: true));
    }
    if (k.tanggungan > k.anggota.length) {
      t.add(Temuan(
          'Tanggungan (${k.tanggungan}) melebihi jumlah anggota tercatat (${k.anggota.length})',
          anomali: true));
    }
    return t;
  }
}
