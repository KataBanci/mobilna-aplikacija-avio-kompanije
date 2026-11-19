part of '../booking_screens.dart';

class DetailsScreen extends StatefulWidget {
  final Booking b;
  const DetailsScreen({super.key, required this.b});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    final image =
        {
          'FCO': 'rome.jpg',
          'CDG': 'Paris.jpg',
          'LHR': 'london.jpg',
          'VIE': 'vienna.jpg',
        }[b.code(b.destination)] ??
        'plane-hero.jpg.jpg';
    return BookingPage(
      b: b,
      title: 'Detalji leta',
      step: 2,
      bottom: action(
        AuthService.currentUser == null ? 'Prijavi se za nastavak' : 'Nastavi',
        () {
          if (AuthService.currentUser == null) {
            open(
              context,
              const Scaffold(
                body: SafeArea(
                  child: GuestSignIn(
                    message:
                        'Za nastavak rezervacije prijavi se ili napravi nalog.',
                  ),
                ),
              ),
            );
            return;
          }
          open(context, PassengerScreen(b: b));
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/images/$image',
              height: 190,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            b.route,
            style: const TextStyle(fontFamily: 'AirVistaSerif', fontSize: 25),
          ),
          spaced(small('${b.dateLabel} · ${b.count} putnika')),
          panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✈  ${b.flight.airline}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 22),
                flightTimes(b, b.flight),
                const Divider(height: 32),
                small(
                  '${b.flight.number} · ${b.flight.aircraft}\nLični predmet do 4 kg uključen.\nRučni prtljag do 8 kg prema izabranoj tarifi.',
                ),
              ],
            ),
          ),
          const Text(
            'Izaberite svoju tarifu',
            style: TextStyle(fontFamily: 'AirVistaSerif', fontSize: 23),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() => b.fare = i);
                  b.update();
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: b.fare == i ? const Color(0xFFF0F4EE) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: b.fare == i ? green : const Color(0xFFE3E7E0),
                      width: b.fare == i ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            b.fare == i
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: green,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ['Osnovni', 'Standardni', 'Fleksibilni'][i],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${b.flight.price + [0, 30, 60][i]} €',
                            style: const TextStyle(fontSize: 21, color: green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      small(
                        [
                          '✓ Lični predmet',
                          '✓ Lični predmet\n✓ Ručni prtljag\n✓ Izbor sedišta',
                          '✓ Lični predmet i ručni prtljag\n✓ Izbor sedišta\n✓ Fleksibilna promena rezervacije',
                        ][i],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          small(
            'Cena je po putniku i smeru. Biznis klasa: doplata 100 € po putniku i smeru.',
          ),
        ],
      ),
    );
  }
}
