import 'package:flutter/material.dart';

import '../../app/services.dart';
import '../../shared/widgets/primary_button.dart';
import '../navigation/root_shell.dart';
import 'auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService(widget.services.apiClient, widget.services.tokenStore);
      await authService.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RootShell(services: widget.services)),
      );
    } catch (error) {
      setState(() {
        _errorMessage = 'Unable to sign up right now. Try again in a moment.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1115), Color(0xFF152032), Color(0xFF1C2C43)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              Text(
                'Create your stage',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Build your artist profile and start sharing tracks.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Create Account',
                onPressed: _signup,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
