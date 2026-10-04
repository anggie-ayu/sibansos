import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../providers/keluarga_provider.dart';

class PeriodeDropdown extends StatelessWidget {
  const PeriodeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<KeluargaProvider>();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Text('Periode: ', style: TextStyle(color: AppColors.muted)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.line),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: p.periodeAktif,
            items: [
              for (final o in p.periodeOptions)
                DropdownMenuItem(value: o, child: Text(periodeLabel(o))),
            ],
            onChanged: (v) => p.setPeriode(v!),
          ),
        ),
      ),
    ]);
  }
}
