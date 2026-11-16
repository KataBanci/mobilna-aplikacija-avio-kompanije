import 'package:flutter/material.dart';
import 'package:aviokomopanija/consts/app_colors.dart';
import 'package:aviokomopanija/screens/welcome_screen.dart';
import 'package:aviokomopanija/services/auth_service.dart';

import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void logout(BuildContext context) {
    AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  void showDetails(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final name = user?['name'] ?? 'Gost';
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    final menu = [
      ('Lični podaci', Icons.person_outline),
      ('Sačuvani putnici', Icons.people_outline),
      ('Načini plaćanja', Icons.credit_card_outlined),
      ('Program lojalnosti', Icons.shield_outlined),
      ('Obaveštenja', Icons.notifications_none_rounded),
      ('Centar za pomoć', Icons.help_outline),
      (user == null ? 'Prijava' : 'Odjavi se', Icons.logout),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightScaffoldColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Nazad',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: const Row(
          children: [
            Icon(Icons.near_me, size: 32, color: AppColors.lightPrimary),
            SizedBox(width: 8),
            Text(
              'airvista',
              style: TextStyle(
                fontSize: 25,
                letterSpacing: -0.8,
                color: AppColors.lightPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Podešavanja',
            icon: const Icon(Icons.settings_outlined, size: 26),
            onPressed: () => showDetails(
              context,
              'Podešavanja',
              'Podešavanja još nisu dostupna.',
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 34,
                  height: 1.2,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDDDFD9)),
                    ),
                    child: CircleAvatar(
                      radius: 37,
                      backgroundColor: const Color(0xFFE2E9E1),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 27,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user?['email'] ?? 'Prijavi se na svoj nalog',
                          style: const TextStyle(
                            color: Color(0xFF7D827D),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shadowColor: const Color(0x10000000),
                color: const Color(0xFFFEFEFC),
                surfaceTintColor: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    for (int index = 0; index < menu.length; index++) ...[
                      ListTile(
                        minTileHeight: 53,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        horizontalTitleGap: 18,
                        leading: Icon(
                          menu[index].$2,
                          size: 25,
                          color: const Color(0xFF43504F),
                        ),
                        title: Text(
                          menu[index].$1,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF303B3C),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          size: 24,
                          color: Color(0xFF8D9692),
                        ),
                        onTap: () {
                          if (menu[index].$1 == 'Obaveštenja') {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          } else if (index == menu.length - 1) {
                            logout(context);
                          } else if (index == 0) {
                            showDetails(
                              context,
                              'Lični podaci',
                              user == null
                                  ? 'Prijavi se da vidiš svoje podatke.'
                                  : '$name\n${user['email']}',
                            );
                          } else {
                            showDetails(
                              context,
                              menu[index].$1,
                              'Ova funkcionalnost još nije dostupna.',
                            );
                          }
                        },
                      ),
                      if (index < menu.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          indent: 18,
                          endIndent: 18,
                          color: Color(0xFFEEF0EB),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEBEEE8))),
        ),
        child: NavigationBar(
          height: 68,
          selectedIndex: 3,
          elevation: 0,
          backgroundColor: AppColors.lightScaffoldColor,
          indicatorColor: Colors.transparent,
          onDestinationSelected: (index) {
            if (index == 0) Navigator.maybePop(context);
            if (index == 1 || index == 2) {
              showDetails(
                context,
                index == 1 ? 'Pretraga' : 'Putovanja',
                'Ova funkcionalnost još nije dostupna.',
              );
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Početna',
            ),
            NavigationDestination(icon: Icon(Icons.search), label: 'Pretraga'),
            NavigationDestination(
              icon: Icon(Icons.confirmation_number_outlined),
              label: 'Putovanja',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.lightPrimary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
