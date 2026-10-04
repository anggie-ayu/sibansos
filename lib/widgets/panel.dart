import 'package:flutter/material.dart';
import '../core/theme.dart';

class Panel extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  const Panel({super.key, this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Expanded(
                  child: Text(title!,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
              if (trailing != null) trailing!,
            ]),
          ),
        child,
      ]),
    );
  }
}
