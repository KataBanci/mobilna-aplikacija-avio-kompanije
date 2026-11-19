part of '../booking_screens.dart';

class ConfirmationScreen extends StatelessWidget {
  final Booking b;
  const ConfirmationScreen({super.key, required this.b});
  @override
  Widget build(BuildContext context) => BookingPage(
    b: b,
    title: '',
    step: 7,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEDF3EE),
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: green,
              child: Icon(Icons.check_rounded, color: Colors.white, size: 34),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Karta je uspešno kupljena!',
          semanticsLabel: 'Probna kupovina karte je uspešno završena.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'AirVistaSerif',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: green,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Probna rezervacija za ${b.destination.split(' (').first} je potvrđena.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 20),
        reservationCard(b),
        action(
          'Pregledaj rezervaciju',
          () => open(context, ReservationScreen(b: b)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => goHome(context, b),
          child: const Text('Nazad na početak'),
        ),
        small(
          'Probna rezervacija · karta nije izdata. Podaci se čuvaju do zatvaranja aplikacije.',
        ),
      ],
    ),
  );
}
