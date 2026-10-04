import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/anomali.dart';
import '../core/format.dart';
import '../core/scoring.dart';
import '../core/seed.dart';
import '../models/keluarga.dart';

class RekapKelurahan {
  final String nama;
  int total = 0, sangat = 0, miskin = 0, rentan = 0, tidak = 0, verif = 0, sumSkor = 0;
  RekapKelurahan(this.nama);
  double get rata => total == 0 ? 0 : sumSkor / total;
}

class KeluargaProvider extends ChangeNotifier {
  static const _key = 'keluarga_v2';
  List<Keluarga> _all = [];
  Map<String, List<Temuan>> _temuan = {};
  String query = '';
  String _periode = 'all';

  List<Keluarga> get all => _all;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = jsonDecode(p.getString(_key) ?? '[]') as List;
    _all = raw.map((e) => Keluarga.fromJson(Map<String, dynamic>.from(e))).toList();
    _hitungUlang();
    notifyListeners();
  }

  void _hitungUlang() {
    final pm = Pemeriksa(_all);
    _temuan = {for (final k in _all) k.id: pm.periksa(k)};
  }

  Future<void> _save() async {
    _hitungUlang();
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(_all.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  // ---------- pencarian & periode ----------
  List<Keluarga> get items {
    final q = query.toLowerCase();
    return _all
        .where((k) =>
            k.kepala.toLowerCase().contains(q) ||
            k.noKk.contains(q) ||
            k.kelurahan.toLowerCase().contains(q))
        .toList();
  }

  void search(String q) {
    query = q;
    notifyListeners();
  }

  List<String> get periodeOptions {
    final s = _all.map((k) => periodeKey(k.tanggalUpdate)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    return ['all', ...s];
  }

  String get periodeAktif => periodeOptions.contains(_periode) ? _periode : 'all';

  void setPeriode(String v) {
    _periode = v;
    notifyListeners();
  }

  List<Keluarga> get inPeriode => periodeAktif == 'all'
      ? _all
      : _all.where((k) => periodeKey(k.tanggalUpdate) == periodeAktif).toList();

  List<String> get kelurahanList =>
      {...kKelurahanDefault, ..._all.map((k) => k.kelurahan)}.toList()..sort();

  // ---------- skor, anomali, rekap ----------
  Keluarga? byId(String id) {
    for (final k in _all) {
      if (k.id == id) return k;
    }
    return null;
  }

  HasilScore skor(Keluarga k) => Scoring.hitung(k);
  List<Temuan> temuanOf(String id) => _temuan[id] ?? const [];
  bool punyaAnomali(Keluarga k) => temuanOf(k.id).any((t) => t.anomali);
  bool punyaValidasi(Keluarga k) => temuanOf(k.id).any((t) => !t.anomali);

  String statusBansos(Keluarga k) {
    if (!skor(k).layakDiajukan) return 'Tidak diprioritaskan';
    if (!k.terverifikasi && punyaAnomali(k)) return 'Tunda - cek anomali';
    if (!k.terverifikasi) return 'Menunggu verifikasi';
    return 'Layak menerima';
  }

  List<Keluarga> get ranking {
    final l = [...inPeriode];
    l.sort((a, b) {
      final c = skor(b).total.compareTo(skor(a).total);
      return c != 0 ? c : a.pendapatan.compareTo(b.pendapatan);
    });
    return l;
  }

  List<RekapKelurahan> get rekap {
    final m = <String, RekapKelurahan>{};
    for (final k in inPeriode) {
      final r = m.putIfAbsent(k.kelurahan, () => RekapKelurahan(k.kelurahan));
      final h = skor(k);
      r.total++;
      r.sumSkor += h.total;
      switch (h.klasifikasi) {
        case 'Sangat Miskin':
          r.sangat++;
        case 'Miskin':
          r.miskin++;
        case 'Rentan Miskin':
          r.rentan++;
        default:
          r.tidak++;
      }
      if (!k.terverifikasi) r.verif++;
    }
    return m.values.toList()..sort((a, b) => a.nama.compareTo(b.nama));
  }

  // ---------- CRUD ----------
  Future<void> add(Keluarga k) async {
    _all.add(k);
    await _save();
  }

  Future<void> update(Keluarga k) async {
    _all[_all.indexWhere((x) => x.id == k.id)] = k;
    await _save();
  }

  Future<void> remove(String id) async {
    _all.removeWhere((x) => x.id == id);
    await _save();
  }

  Future<void> setVerifikasi(String id, bool v) async {
    final i = _all.indexWhere((x) => x.id == id);
    _all[i] = _all[i].copyWith(terverifikasi: v);
    await _save();
  }

  Future<void> muatContoh() async {
    _all.removeWhere((k) => k.id.startsWith('seed'));
    _all.addAll(contohData());
    await _save();
  }
}
