import 'package:flutter/material.dart';
import '../core/theme.dart';

class ScoreBar extends StatelessWidget {
  final String label;
  final int nilai, maks;
  const ScoreBar(this.label, this.nilai, this.maks, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(children: [
        Row(children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Text('$nilai / $maks', style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: maks == 0 ? 0 : nilai / maks,
            minHeight: 8,
            backgroundColor: AppColors.line,
            color: AppColors.primary,
          ),
        ),
      ]),
    );
  }
}
