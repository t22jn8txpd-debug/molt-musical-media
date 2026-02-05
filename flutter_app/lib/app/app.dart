import 'package:flutter/material.dart';

import '../features/auth/auth_gate.dart';
import 'theme.dart';

class MoltApp extends StatelessWidget {
  const MoltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Molt Musical Media',
      debugShowCheckedModeBanner: false,
      theme: buildMoltTheme(),
      home: const AuthGate(),
    );
  }
}
