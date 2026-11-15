import 'package:flutter/material.dart';
import 'package:aviokomopanija/consts/app_colors.dart';
import 'package:aviokomopanija/screens/welcome_screen.dart';
import 'package:aviokomopanija/services/auth_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightScaffoldColor,
        title: const Row(
          children: [
            Icon(Icons.near_me, color: AppColors.lightPrimary),
            SizedBox(width: 8),
            Text(
              'airvista',
              style: TextStyle(
                color: AppColors.lightPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Administracija',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dobro došli, admin.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'AirVista kontrolni panel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Upravljanje',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in const [
              ('Letovi', 'Raspored i ponuda letova', Icons.flight_takeoff),
              ('Destinacije', 'Gradovi i mesta za putovanje', Icons.public),
              ('Korisnici', 'Pregled korisničkih naloga', Icons.people_outline),
              (
                'Rezervacije',
                'Pregled rezervacija putnika',
                Icons.confirmation_number_outlined,
              ),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEAF0E9),
                      child: Icon(item.$3, color: AppColors.lightPrimary),
                    ),
                    title: Text(
                      item.$1,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(item.$2),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(item.$1),
                        content: const Text(
                          'Upravljanje podacima povezujemo u narednim koracima.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Zatvori'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Razvojna verzija · lokalni probni nalozi',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                AuthService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const WelcomeScreen(),
                  ),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Odjavi se'),
            ),
          ],
        ),
      ),
    );
  }
}
