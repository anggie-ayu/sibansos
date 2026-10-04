import '../models/keluarga.dart';

/// Data contoh untuk demo (termasuk beberapa data janggal sengaja).
List<Keluarga> contohData() {
  final now = DateTime.now();
  var n = 0;
  String kk(int i) => '35780123${i.toString().padLeft(8, '0')}';

  Keluarga mk(String noKk, String kepala, String kel, String rt, int inc, int tang,
      List<String> aset, String kerja, String rumah, int hari,
      List<(String, String, int)> ang, {bool ver = false}) {
    n++;
    String nik(int m) => '35780100${(n * 10 + m).toString().padLeft(8, '0')}';
    return Keluarga(
      id: 'seed$n', noKk: noKk, kepala: kepala, nikKepala: nik(0),
      alamat: 'Jl. Contoh No. ${n * 3}', rtRw: rt, kelurahan: kel,
      pendapatan: inc, tanggungan: tang, aset: aset, pekerjaan: kerja, rumah: rumah,
      tanggalUpdate: now.subtract(Duration(days: hari)), terverifikasi: ver,
      anggota: [
        for (var i = 0; i < ang.length; i++)
          Anggota(nik: nik(i + 1), nama: ang[i].$1, hubungan: ang[i].$2, usia: ang[i].$3),
      ],
    );
  }

  const ist = 'Istri / suami', anak = 'Anak', ortu = 'Orang tua', fam = 'Famili lain';
  return [
    mk(kk(1), 'Slamet Riyadi', 'Wonokromo', '03 / 05', 900000, 4, [], kPekerjaan[1], kRumah[0], 5,
        [('Sri Wahyuni', ist, 42), ('Dimas Riyadi', anak, 16), ('Putri Riyadi', anak, 9), ('Rina Riyadi', anak, 5)],
        ver: true),
    mk(kk(2), 'Siti Aminah', 'Jagir', '01 / 02', 1300000, 3, [kAset[0]], kPekerjaan[2], kRumah[1], 12,
        [('Hasan', anak, 14), ('Laila', anak, 10), ('Marfuah', ortu, 68)], ver: true),
    mk(kk(3), 'Budi Hartono', 'Wonokromo', '04 / 05', 3000000, 2, [kAset[0]], kPekerjaan[2], kRumah[1], 20,
        [('Ani Hartono', ist, 35), ('Fajar Hartono', anak, 8)]),
    mk(kk(4), 'Agus Prasetyo', 'Sawunggaling', '05 / 03', 1100000, 3, [kAset[0], kAset[1]], kPekerjaan[1], kRumah[1], 8,
        [('Rini', ist, 38), ('Ayu', anak, 12), ('Doni', anak, 7)]),
    mk(kk(5), 'Nur Hidayati', 'Darmo', '02 / 01', 4800000, 1, [kAset[0], kAset[3]], kPekerjaan[3], kRumah[2], 15,
        [('Rendi', anak, 10)], ver: true),
    mk(kk(6), 'Eko Wahyudi', 'Jagir', '06 / 04', 0, 2, [], kPekerjaan[3], kRumah[1], 3,
        [('Wati', ist, 30), ('Bayu', anak, 4)]),
    mk(kk(2), 'Dewi Lestari', 'Sawunggaling', '02 / 02', 1000000, 2, [], kPekerjaan[0], kRumah[0], 10,
        [('Ari', anak, 6), ('Ina', anak, 3)]),
    mk(kk(8), 'Joko Santoso', 'Darmo', '07 / 01', 1800000, 5, [kAset[2]], kPekerjaan[1], kRumah[1], 25,
        [('Tini', ist, 40), ('Adit', anak, 17), ('Bagas', anak, 14), ('Citra', anak, 11), ('Dinda', anak, 6)],
        ver: true),
    mk(kk(9), 'Hendra Gunawan', 'Wonokromo', '01 / 06', 1400000, 6, [], kPekerjaan[2], kRumah[0], 7,
        [('Mira', ist, 33), ('Kevin', anak, 5)]),
    mk(kk(10), 'Sumarni', 'Jagir', '03 / 03', 800000, 1, [], kPekerjaan[0], kRumah[0], 220,
        [('Cucu Sumarni', fam, 9)], ver: true),
    mk(kk(11), 'Tono Prakoso', 'Darmo', '04 / 02', 5500000, 0, [kAset[0]], kPekerjaan[0], kRumah[2], 2,
        [('Lia', ist, 29)]),
    mk(kk(12), 'Rahmat Hidayat', 'Sawunggaling', '05 / 05', 1200000, 2, [], kPekerjaan[1], kRumah[1], 40,
        [('Yuni', ist, 31), ('Salsa', anak, 7)], ver: true),
  ];
}
