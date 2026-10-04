import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'pages/auth/login_page.dart';
import 'providers/auth_provider.dart';
import 'providers/keluarga_provider.dart';
import 'widgets/app_shell.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()..load()),
      ChangeNotifierProvider(create: (_) => KeluargaProvider()..load()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return MaterialApp(
      title: 'SiBansos',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: !auth.ready
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : auth.loggedIn
              ? const HomeShell()
              : const LoginPage(),
    );
  }
}
