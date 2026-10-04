import '../models/keluarga.dart';

class Komponen {
  final String nama;
  final int nilai, maks;
  const Komponen(this.nama, this.nilai, this.maks);
}

class HasilScore {
  final List<Komponen> komponen;
  const HasilScore(this.komponen);

  int get total => komponen.fold(0, (s, k) => s + k.nilai);

  String get klasifikasi => total >= Scoring.batasSangatMiskin
      ? 'Sangat Miskin'
      : total >= Scoring.batasMiskin
          ? 'Miskin'
          : total >= Scoring.batasRentan
              ? 'Rentan Miskin'
              : 'Tidak Miskin';

  String get prioritas => total >= Scoring.batasSangatMiskin
      ? 'Prioritas 1'
      : total >= Scoring.batasMiskin
          ? 'Prioritas 2'
          : total >= Scoring.batasRentan
              ? 'Prioritas 3'
              : 'Tidak prioritas';

  /// Prioritas 1 dan 2 dianggap layak diajukan untuk bansos.
  bool get layakDiajukan => total >= Scoring.batasMiskin;
}

/// Semakin TINGGI skor = semakin miskin = semakin prioritas menerima bansos.
/// Total maksimal 100 poin. Ubah angka di sini bila parameter berubah.
class Scoring {
  static const batasSangatMiskin = 75;
  static const batasMiskin = 55;
  static const batasRentan = 35;

  static const aspek = [
    ('Pendapatan bulanan', 30),
    ('Aset & harta', 20),
    ('Kondisi rumah', 20),
    ('Status pekerjaan', 15),
    ('Jumlah tanggungan', 15),
  ];

  // (batas pendapatan maksimal, poin)
  static const _pendapatan = [
    (1000000, 30), (1500000, 24), (2500000, 16), (3500000, 8),
  ];

  // Pengurang poin untuk tiap aset yang dimiliki (mulai dari 20).
  static const _bobotAset = {
    'Sepeda motor': 5, 'Mobil': 12, 'Tanah / lahan': 8,
    'Emas / tabungan': 6, 'Ternak': 3,
  };

  static HasilScore hitung(Keluarga k) {
    var p = 0;
    for (final (batas, poin) in _pendapatan) {
      if (k.pendapatan <= batas) {
        p = poin;
        break;
      }
    }

    var a = 20;
    for (final s in k.aset) {
      a -= _bobotAset[s] ?? 0;
    }
    if (a < 0) a = 0;

    final r = switch (k.rumah) { 'Tidak layak huni' => 20, 'Semi-permanen' => 12, _ => 4 };
    final w = switch (k.pekerjaan) {
      'Tidak bekerja' => 15,
      'Buruh harian / serabutan' => 12,
      'Pekerja informal / pedagang kecil' => 8,
      _ => 2,
    };
    final t = k.tanggungan >= 5 ? 15 : k.tanggungan >= 3 ? 10 : k.tanggungan >= 1 ? 5 : 0;

    return HasilScore([
      Komponen(aspek[0].$1, p, aspek[0].$2),
      Komponen(aspek[1].$1, a, aspek[1].$2),
      Komponen(aspek[2].$1, r, aspek[2].$2),
      Komponen(aspek[3].$1, w, aspek[3].$2),
      Komponen(aspek[4].$1, t, aspek[4].$2),
    ]);
  }
}
