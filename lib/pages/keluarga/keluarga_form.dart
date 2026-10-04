import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/keluarga.dart';
import '../../providers/keluarga_provider.dart';
import '../../widgets/panel.dart';

void bukaForm(BuildContext context, {Keluarga? data}) => Navigator.push(
    context, MaterialPageRoute(builder: (_) => KeluargaFormPage(data: data)));

class _Agt {
  final nik = TextEditingController();
  final nama = TextEditingController();
  final usia = TextEditingController();
  String hubungan = kHubungan[1];
  _Agt();
  _Agt.from(Anggota a) {
    nik.text = a.nik;
    nama.text = a.nama;
    usia.text = '${a.usia}';
    hubungan = a.hubungan;
  }
  void dispose() {
    nik.dispose();
    nama.dispose();
    usia.dispose();
  }
}

/// Form tambah / ubah: kepala keluarga + kondisi ekonomi + anggota dalam satu halaman.
class KeluargaFormPage extends StatefulWidget {
  final Keluarga? data;
  const KeluargaFormPage({super.key, this.data});
  @override
  State<KeluargaFormPage> createState() => _KeluargaFormPageState();
}

class _KeluargaFormPageState extends State<KeluargaFormPage> {
  final _form = GlobalKey<FormState>();
  late final _noKk = TextEditingController(text: widget.data?.noKk);
  late final _kepala = TextEditingController(text: widget.data?.kepala);
  late final _nikKepala = TextEditingController(text: widget.data?.nikKepala);
  late final _alamat = TextEditingController(text: widget.data?.alamat);
  late final _rtRw = TextEditingController(text: widget.data?.rtRw);
  late final _pendapatan = TextEditingController(
      text: widget.data == null ? '' : '${widget.data!.pendapatan}');
  late final _tanggungan = TextEditingController(
      text: widget.data == null ? '' : '${widget.data!.tanggungan}');
  late String _kelurahan = widget.data?.kelurahan ?? '';
  late final Set<String> _aset = <String>{...?widget.data?.aset};
  late String _pekerjaan = widget.data?.pekerjaan ?? kPekerjaan[0];
  late String _rumah = widget.data?.rumah ?? kRumah[1];
  late DateTime _tgl = widget.data?.tanggalUpdate ?? DateTime.now();
  late final List<_Agt> _agt = [
    for (final a in widget.data?.anggota ?? <Anggota>[]) _Agt.from(a)
  ];

  static final _d16 = RegExp(r'^\d{16}$');

  String? _wajib(String? v, String l) =>
      (v == null || v.trim().isEmpty) ? '$l wajib diisi' : null;
  String? _nik(String? v, String l) => _d16.hasMatch(v ?? '') ? null : '$l harus 16 digit angka';
  String? _angka(String? v, String l, {int maks = 99999999}) {
    if (v == null || v.isEmpty) return '$l wajib diisi';
    if (v.length > 9 || int.parse(v) > maks) return '$l terlalu besar';
    return null;
  }

  String _judul(String s) => s
      .trim()
      .split(RegExp(r'\s+'))
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _tgl.isAfter(now) ? now : _tgl,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (d != null) setState(() => _tgl = d);
  }

  Future<void> _simpan() async {
    if (!_form.currentState!.validate()) return;
    final prov = context.read<KeluargaProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final edit = widget.data != null;
    final k = Keluarga(
      id: widget.data?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      noKk: _noKk.text.trim(),
      kepala: _kepala.text.trim(),
      nikKepala: _nikKepala.text.trim(),
      alamat: _alamat.text.trim(),
      rtRw: _rtRw.text.trim(),
      kelurahan: _judul(_kelurahan),
      pendapatan: int.parse(_pendapatan.text),
      tanggungan: int.parse(_tanggungan.text),
      aset: _aset.toList(),
      pekerjaan: _pekerjaan,
      rumah: _rumah,
      tanggalUpdate: _tgl,
      terverifikasi: false, // data baru/diubah perlu diverifikasi ulang
      anggota: [
        for (final a in _agt)
          Anggota(
              nik: a.nik.text.trim(),
              nama: a.nama.text.trim(),
              hubungan: a.hubungan,
              usia: int.parse(a.usia.text)),
      ],
    );
    if (edit) {
      await prov.update(k);
    } else {
      await prov.add(k);
    }
    nav.pop();
    messenger.showSnackBar(SnackBar(
        content: Text(edit ? 'Perubahan disimpan' : 'Data keluarga ditambahkan')));
  }

  @override
  void dispose() {
    for (final c in [_noKk, _kepala, _nikKepala, _alamat, _rtRw, _pendapatan, _tanggungan]) {
      c.dispose();
    }
    for (final a in _agt) {
      a.dispose();
    }
    super.dispose();
  }

  Widget _tf(TextEditingController c, String label, String? Function(String?) v,
          {bool angka = false, String? hint, String? prefix}) =>
      TextFormField(
        controller: c,
        keyboardType: angka ? TextInputType.number : null,
        inputFormatters: angka ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(labelText: label, hintText: hint, prefixText: prefix),
        validator: v,
      );

  Widget _dd(String label, String value, List<String> opts, ValueChanged<String> on) =>
      DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [for (final o in opts) DropdownMenuItem(value: o, child: Text(o))],
        onChanged: (v) => on(v!),
      );

  Widget _row(List<Widget> w, {List<int>? flex}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < w.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(flex: flex?[i] ?? 1, child: w[i]),
          ],
        ],
      );

  Widget _agtRow(int i) {
    final a = _agt[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _row(flex: [3, 3, 1, 2, 1], [
        _tf(a.nama, 'Nama anggota', (v) => _wajib(v, 'Nama')),
        _tf(a.nik, 'NIK', (v) => _nik(v, 'NIK'), angka: true),
        _tf(a.usia, 'Usia', (v) => _angka(v, 'Usia', maks: 120), angka: true),
        _dd('Hubungan', a.hubungan, kHubungan, (v) => setState(() => a.hubungan = v)),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Hapus anggota',
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () => setState(() {
              _agt.removeAt(i).dispose();
            }),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.data != null;
    const gap = SizedBox(height: 12);
    final kelOpsi = context.read<KeluargaProvider>().kelurahanList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(edit ? 'Ubah data keluarga' : 'Tambah keluarga'),
      ),
      body: Form(
        key: _form,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: ListView(padding: const EdgeInsets.all(24), children: [
              Panel(
                title: '1. Data keluarga & kepala keluarga',
                child: Column(children: [
                  _row([
                    _tf(_noKk, 'No. KK (16 digit)', (v) => _nik(v, 'No. KK'), angka: true),
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: _kelurahan),
                      optionsBuilder: (v) => kelOpsi
                          .where((o) => o.toLowerCase().contains(v.text.toLowerCase())),
                      onSelected: (s) => _kelurahan = s,
                      fieldViewBuilder: (ctx, ctl, focus, _) => TextFormField(
                        controller: ctl,
                        focusNode: focus,
                        decoration: const InputDecoration(labelText: 'Desa / Kelurahan'),
                        onChanged: (v) => _kelurahan = v,
                        validator: (v) => _wajib(v, 'Kelurahan'),
                      ),
                    ),
                  ]),
                  gap,
                  _row(flex: [3, 1], [
                    _tf(_alamat, 'Alamat', (v) => _wajib(v, 'Alamat')),
                    _tf(_rtRw, 'RT / RW', (v) => _wajib(v, 'RT/RW'), hint: '03 / 05'),
                  ]),
                  gap,
                  _row([
                    _tf(_kepala, 'Nama kepala keluarga', (v) => _wajib(v, 'Nama kepala keluarga')),
                    _tf(_nikKepala, 'NIK kepala keluarga', (v) => _nik(v, 'NIK'), angka: true),
                  ]),
                ]),
              ),
              gap,
              Panel(
                title: '2. Kondisi ekonomi',
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _row([
                    _tf(_pendapatan, 'Pendapatan bulanan', (v) => _angka(v, 'Pendapatan'),
                        angka: true, prefix: 'Rp '),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _tf(_tanggungan, 'Jumlah tanggungan',
                          (v) => _angka(v, 'Tanggungan', maks: 30), angka: true),
                      TextButton(
                        onPressed: () => setState(() => _tanggungan.text = '${_agt.length}'),
                        child: Text('Isi otomatis dari jumlah anggota (${_agt.length})'),
                      ),
                    ]),
                  ]),
                  gap,
                  _row([
                    _dd('Status pekerjaan kepala keluarga', _pekerjaan, kPekerjaan,
                        (v) => setState(() => _pekerjaan = v)),
                    _dd('Kondisi rumah', _rumah, kRumah, (v) => setState(() => _rumah = v)),
                  ]),
                  gap,
                  const Text('Kepemilikan aset & harta',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final a in kAset)
                      FilterChip(
                        label: Text(a),
                        selected: _aset.contains(a),
                        onSelected: (v) => setState(() {
                          if (v) {
                            _aset.add(a);
                          } else {
                            _aset.remove(a);
                          }
                        }),
                      ),
                  ]),
                  gap,
                  InkWell(
                    onTap: _pilihTanggal,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Tanggal update data',
                          suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
                      child: Text(tanggal(_tgl)),
                    ),
                  ),
                ]),
              ),
              gap,
              Panel(
                title: '3. Anggota keluarga (${_agt.length})',
                trailing: OutlinedButton.icon(
                  onPressed: () => setState(() => _agt.add(_Agt())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah anggota'),
                ),
                child: _agt.isEmpty
                    ? const Text(
                        'Belum ada anggota. Klik "Tambah anggota" untuk mencatat istri/suami, anak, dan anggota lain.',
                        style: TextStyle(color: AppColors.muted))
                    : Column(children: [for (var i = 0; i < _agt.length; i++) _agtRow(i)]),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                    onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                const SizedBox(width: 10),
                FilledButton(onPressed: _simpan, child: const Text('Simpan data')),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
