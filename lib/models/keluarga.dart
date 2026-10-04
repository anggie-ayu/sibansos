const kPekerjaan = [
  'Tidak bekerja',
  'Buruh harian / serabutan',
  'Pekerja informal / pedagang kecil',
  'Pegawai / wiraswasta tetap',
];
const kRumah = ['Tidak layak huni', 'Semi-permanen', 'Permanen'];
const kAset = ['Sepeda motor', 'Mobil', 'Tanah / lahan', 'Emas / tabungan', 'Ternak'];
const kHubungan = ['Istri / suami', 'Anak', 'Orang tua', 'Famili lain'];
const kKelurahanDefault = ['Wonokromo', 'Jagir', 'Sawunggaling', 'Darmo'];

class Anggota {
  final String nik, nama, hubungan;
  final int usia;
  const Anggota({
    required this.nik,
    required this.nama,
    required this.hubungan,
    required this.usia,
  });

  Map<String, dynamic> toJson() =>
      {'nik': nik, 'nama': nama, 'hubungan': hubungan, 'usia': usia};

  factory Anggota.fromJson(Map<String, dynamic> j) => Anggota(
        nik: j['nik'], nama: j['nama'], hubungan: j['hubungan'], usia: j['usia']);
}

class Keluarga {
  final String id, noKk, kepala, nikKepala, alamat, rtRw, kelurahan;
  final int pendapatan, tanggungan;
  final List<String> aset;
  final String pekerjaan, rumah;
  final DateTime tanggalUpdate;
  final bool terverifikasi;
  final List<Anggota> anggota;

  const Keluarga({
    required this.id,
    required this.noKk,
    required this.kepala,
    required this.nikKepala,
    required this.alamat,
    required this.rtRw,
    required this.kelurahan,
    required this.pendapatan,
    required this.tanggungan,
    required this.aset,
    required this.pekerjaan,
    required this.rumah,
    required this.tanggalUpdate,
    required this.terverifikasi,
    required this.anggota,
  });

  /// Kepala keluarga + seluruh anggota.
  int get jiwa => anggota.length + 1;
  List<String> get semuaNik => [nikKepala, ...anggota.map((a) => a.nik)];

  Keluarga copyWith({bool? terverifikasi}) => Keluarga(
        id: id, noKk: noKk, kepala: kepala, nikKepala: nikKepala, alamat: alamat,
        rtRw: rtRw, kelurahan: kelurahan, pendapatan: pendapatan,
        tanggungan: tanggungan, aset: aset, pekerjaan: pekerjaan, rumah: rumah,
        tanggalUpdate: tanggalUpdate,
        terverifikasi: terverifikasi ?? this.terverifikasi, anggota: anggota,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'noKk': noKk, 'kepala': kepala, 'nikKepala': nikKepala,
        'alamat': alamat, 'rtRw': rtRw, 'kelurahan': kelurahan,
        'pendapatan': pendapatan, 'tanggungan': tanggungan, 'aset': aset,
        'pekerjaan': pekerjaan, 'rumah': rumah,
        'tanggalUpdate': tanggalUpdate.toIso8601String(),
        'terverifikasi': terverifikasi,
        'anggota': anggota.map((a) => a.toJson()).toList(),
      };

  factory Keluarga.fromJson(Map<String, dynamic> j) => Keluarga(
        id: j['id'], noKk: j['noKk'], kepala: j['kepala'], nikKepala: j['nikKepala'],
        alamat: j['alamat'], rtRw: j['rtRw'], kelurahan: j['kelurahan'],
        pendapatan: j['pendapatan'], tanggungan: j['tanggungan'],
        aset: List<String>.from(j['aset']), pekerjaan: j['pekerjaan'],
        rumah: j['rumah'], tanggalUpdate: DateTime.parse(j['tanggalUpdate']),
        terverifikasi: j['terverifikasi'],
        anggota: (j['anggota'] as List)
            .map((e) => Anggota.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
