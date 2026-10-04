import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? current;
  bool ready = false;
  bool get loggedIn => current != null;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _users = (jsonDecode(p.getString('users') ?? '[]') as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final c = p.getString('current');
    if (c != null) current = Map<String, dynamic>.from(jsonDecode(c));
    ready = true;
    notifyListeners();
  }

  /// Mengembalikan null jika berhasil, atau pesan error.
  Future<String?> register(Map<String, dynamic> u) async {
    if (_users.any((x) => x['email'] == u['email'])) {
      return 'Email sudah terdaftar';
    }
    _users.add({...u, 'peran': 'Petugas lapangan'});
    final p = await SharedPreferences.getInstance();
    await p.setString('users', jsonEncode(_users));
    return null;
  }

  Future<String?> login(String email, String pass) async {
    final m = _users.where((x) => x['email'] == email && x['password'] == pass);
    if (m.isEmpty) return 'Email atau kata sandi salah';
    current = m.first;
    final p = await SharedPreferences.getInstance();
    await p.setString('current', jsonEncode(current));
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    current = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('current');
    notifyListeners();
  }

  Future<void> updateProfile(String nama, String kelurahan) async {
    current!['nama'] = nama;
    current!['kelurahan'] = kelurahan;
    final i = _users.indexWhere((x) => x['email'] == current!['email']);
    _users[i] = current!;
    final p = await SharedPreferences.getInstance();
    await p.setString('users', jsonEncode(_users));
    await p.setString('current', jsonEncode(current));
    notifyListeners();
  }
}
