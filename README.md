# SiBansos – Sistem Pendataan, Scoring & Bansos (UI Slicing)

Aplikasi Flutter Web hasil UI slicing dari desain yang diusulkan.

## Fitur
- Autentikasi: registrasi, login, logout
- CRUD Data Keluarga: kepala keluarga + anggota dalam satu form, beserta pendapatan,
  tanggungan, aset, status pekerjaan, kondisi rumah, dan tanggal update
- Dashboard: total keluarga, rekap per desa/kelurahan, jumlah perlu verifikasi, filter periode
- Scoring kelayakan (maks. 100 poin) dan peringkat prioritas bansos
- Validasi data & deteksi anomali
- Halaman profil pengguna

Data disimpan di browser (shared_preferences), jadi tetap ada setelah refresh.

## Cara menjalankan
```bash
flutter create --platforms=web .
flutter pub get
flutter run -d chrome
```

## Struktur
lib/core (tema), models, providers (state), pages (auth, keluarga, profil), widgets (layout bersama)

## Tim
| NPM | Nama | Peran | Pembagian tugas |
|-----|------|-------|-----------------|
| ... | ... | Hacker | Setup repo, autentikasi |
| ... | ... | ... | CRUD Data Keluarga |
| ... | ... | ... | Profil & tema |
