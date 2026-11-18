import 'package:flutter/material.dart';
import 'package:aviokomopanija/consts/app_colors.dart';
import 'package:aviokomopanija/screens/welcome_screen.dart';
import 'package:aviokomopanija/services/auth_service.dart';

import 'notifications_screen.dart';
import 'guest_sign_in.dart';
import 'profile_pages.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void logout(BuildContext context) {
    AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  Future<void> openPage(Widget page) async {
    final changed = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => page));
    if (mounted && changed == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const GuestSignIn(
        message: 'Prijavi se ili se registruj da pristupiš svom profilu.',
      );
    }
    final name = user['name'] ?? 'Gost';
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    final menu = [
      (
        'Lični podaci',
        Icons.person_outline,
        () => openPage(const PersonalDetailsPage()),
      ),
      (
        'Sačuvani putnici',
        Icons.people_outline,
        () => openPage(const SavedPassengersPage()),
      ),
      (
        'Načini plaćanja',
        Icons.credit_card_outlined,
        () => openPage(const PaymentMethodsPage()),
      ),
      (
        'Program lojalnosti',
        Icons.shield_outlined,
        () => openPage(const LoyaltyPage()),
      ),
      (
        'Obaveštenja',
        Icons.notifications_none_rounded,
        () => openPage(const NotificationsScreen()),
      ),
      (
        'Centar za pomoć',
        Icons.help_outline,
        () => openPage(const HelpCenterPage()),
      ),
      ('Odjavi se', Icons.logout, () => logout(context)),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightScaffoldColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Nazad',
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
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
                          user['email'] ?? '',
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
                        onTap: menu[index].$3,
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
    );
  }
}
