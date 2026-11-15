import 'package:flutter/material.dart';
import 'package:aviokomopanija/consts/app_colors.dart';
import 'package:aviokomopanija/screens/home_screen.dart';
import 'package:aviokomopanija/screens/login_screen.dart';
import 'package:aviokomopanija/screens/register_screen.dart';
import 'package:aviokomopanija/services/auth_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.near_me,
                size: 64,
                color: AppColors.lightPrimary,
              ),
              const SizedBox(height: 12),
              const Text(
                'airvista',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightPrimary,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Tvoje sledeće\nputovanje počinje ovde.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 34,
                  height: 1.15,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dobro došli u AirVista.\nOtkrijte svet, korak po korak.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.6),
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                ),
                child: const Text('Prijava'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const RegisterScreen(),
                  ),
                ),
                child: const Text('Registracija'),
              ),
              TextButton(
                onPressed: () {
                  AuthService.logout();
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text('Nastavi kao gost'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const Text(
                'DEMO VERZIJA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2,
                  color: AppColors.lightPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dva probna naloga dostupna su pri svakom pokretanju. '
                'Novoregistrovani nalozi važe do restarta aplikacije.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('Administratorska prijava'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
