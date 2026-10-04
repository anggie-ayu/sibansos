import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Layout dua kolom untuk Login & Registrasi (sesuai desain).
class AuthLayout extends StatelessWidget {
  final String headline, subtitle;
  final Widget child;
  const AuthLayout({
    super.key,
    required this.headline,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Expanded(
          child: Container(
            color: AppColors.primary,
            padding: const EdgeInsets.all(56),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 32, height: 1.2,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Text(subtitle,
                      style: const TextStyle(color: Color(0xFFCFE6E0), fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420), child: child),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
