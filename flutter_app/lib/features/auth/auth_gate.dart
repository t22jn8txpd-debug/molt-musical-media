import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../navigation/root_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AppServices _services = AppServices();

  Future<String?> _loadToken() => _services.tokenStore.readToken();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _loadToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data;
        if (token != null && token.isNotEmpty) {
          return RootShell(services: _services);
        }

        return LoginScreen(services: _services);
      },
    );
  }
}
