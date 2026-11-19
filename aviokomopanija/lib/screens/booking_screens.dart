import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/city.dart';
import 'cities_screen.dart';
import '../services/notification_service.dart';
import '../services/catalog_service.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';
import 'guest_sign_in.dart';

part 'booking/root_screen.dart';
part 'booking/search_screen.dart';
part 'booking/results_screen.dart';
part 'booking/details_screen.dart';
part 'booking/passenger_screen.dart';
part 'booking/seats_screen.dart';
part 'booking/extras_screen.dart';
part 'booking/payment_screen.dart';
part 'booking/confirmation_screen.dart';
part 'booking/reservation_screen.dart';
part 'booking/trips_screen.dart';

const green = Color(0xFF244638);
const cream = Color(0xFFFAFAF8);
const muted = Color(0xFF7C837E);
List<String> get airports => <String>{
  'Beograd (BEG)',
  'Rim (FCO)',
  'Pariz (CDG)',
  'London (LHR)',
  'Beč (VIE)',
  for (final f in flights) ...[f.origin, f.destination],
  for (final c in cities)
    if (RegExp(r'^.+ \([A-Z]{3}\)$').hasMatch(c.airport)) c.airport,
}.toList();
void open(BuildContext c, Widget page) =>
    Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => page));
void message(BuildContext c, String text) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(text)));
Widget small(String s) =>
    Text(s, style: const TextStyle(color: muted, fontSize: 12, height: 1.6));
Widget heading(String s) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 16),
  child: Text(
    s,
    style: const TextStyle(
      fontFamily: 'AirVistaSerif',
      fontFamilyFallback: ['serif'],
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.15,
      color: green,
    ),
  ),
);
Widget spaced(Widget w) =>
    Padding(padding: const EdgeInsets.only(bottom: 12), child: w);
Widget labeledField(String label, Widget child) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF59655E),
        ),
      ),
    ),
    child,
  ],
);
Widget panel(Widget w) => Container(
  margin: const EdgeInsets.only(bottom: 16),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFECEEE8)),
    boxShadow: const [
      BoxShadow(color: Color(0x05000000), blurRadius: 14, offset: Offset(0, 4)),
    ],
  ),
  child: Material(type: MaterialType.transparency, child: w),
);
Widget action(String s, VoidCallback f) => SizedBox(
  width: double.infinity,
  height: 50,
  child: FilledButton(onPressed: f, child: Text(s)),
);

String? validatePhone(String value) {
  if (!RegExp(r'\d').hasMatch(value) ||
      !RegExp(r'^\+?[0-9\s()./-]+$').hasMatch(value)) {
    return 'Unesite broj telefona.';
  }
  return null;
}

class BookingPage extends StatelessWidget {
  final Booking b;
  final String title;
  final int step;
  final Widget child;
  final Widget? bottom;
  const BookingPage({
    super.key,
    required this.b,
    required this.title,
    required this.step,
    required this.child,
    this.bottom,
  });
  @override
  Widget build(BuildContext context) =>
      AuthService.currentUser == null && step > 2
      ? const Scaffold(
          body: SafeArea(
            child: GuestSignIn(
              message: 'Prijavi se ili se registruj da rezervišeš let.',
            ),
          ),
        )
      : Scaffold(
          bottomNavigationBar: NavigationBar(
            selectedIndex: step == 7 ? 2 : 1,
            onDestinationSelected: (i) {
              goHome(context, b, i);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                label: 'Istraži',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Pretraga',
              ),
              NavigationDestination(
                icon: Icon(Icons.airplane_ticket_outlined),
                label: 'Putovanja',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                label: 'Profil',
              ),
            ],
          ),
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Nazad',
              icon: const Icon(Icons.arrow_back_rounded, size: 21),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              IconButton(
                tooltip: 'Početna',
                icon: const Icon(Icons.home_outlined, size: 22),
                onPressed: () => goHome(context, b),
              ),
              const SizedBox(width: 8),
            ],
            title: const Text(
              'AirVista',
              style: TextStyle(fontFamily: 'AirVistaSerif', color: green),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  if (step < 7)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: List.generate(
                          7,
                          (i) => Expanded(
                            child: Container(
                              height: 3,
                              margin: const EdgeInsets.only(right: 5),
                              color: i < step ? green : const Color(0xFFE5E9E2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (step < 7) small('KORAK $step OD 7'),
                          if (title.isNotEmpty) heading(title),
                          child,
                        ],
                      ),
                    ),
                  ),
                  if (bottom != null)
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: bottom,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
}
