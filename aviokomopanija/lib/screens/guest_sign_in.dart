import 'package:flutter/material.dart';

import 'auth/login.dart';
import 'auth/register.dart';

class GuestSignIn extends StatelessWidget {
  final String message;
  const GuestSignIn({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Prijavi se ili se registruj',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
            ),
            child: const Text('Prijavi se'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
            ),
            child: const Text('Registruj se'),
          ),
        ],
      ),
    ),
  );
}
