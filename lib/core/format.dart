const _bln = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

String rupiah(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp $b';
}

String tanggal(DateTime d) => '${d.day} ${_bln[d.month - 1]} ${d.year}';

/// Kunci periode bulanan, mis. "2026-10".
String periodeKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

String periodeLabel(String key) {
  if (key == 'all') return 'Semua periode';
  final p = key.split('-');
  return '${_bln[int.parse(p[1]) - 1]} ${p[0]}';
}
