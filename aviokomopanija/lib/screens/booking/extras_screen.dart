part of '../booking_screens.dart';

class ExtrasScreen extends StatefulWidget {
  final Booking b;
  const ExtrasScreen({super.key, required this.b});
  @override
  State<ExtrasScreen> createState() => _ExtrasScreenState();
}

class _ExtrasScreenState extends State<ExtrasScreen> {
  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    return BookingPage(
      b: b,
      title: 'Dodatne usluge',
      step: 5,
      bottom: action('Nastavi', () => open(context, PaymentScreen(b: b))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          spaced(
            small(
              'Prilagodite putovanje svojim željama. Cene dodataka su po putniku i važe za sve putnike na odlaznom letu.',
            ),
          ),
          for (int i = 0; i < 4; i++)
            panel(
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      [
                        Icons.luggage_outlined,
                        Icons.flight_takeoff,
                        Icons.shield_outlined,
                        Icons.restaurant_outlined,
                      ][i],
                      color: green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            'Dodatni prtljag',
                            'Prioritetno ukrcavanje',
                            'Putno osiguranje',
                            'Obrok tokom leta',
                          ][i],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        small(
                          [
                            'Predati prtljag od 20 kg',
                            'Ranije ukrcavanje u avion',
                            'Zaštita tokom putovanja',
                            'Obrok po vašem izboru',
                          ][i],
                        ),
                        Text(
                          '${[29, 12, 9, 11][i]} € po putniku',
                          style: const TextStyle(
                            fontSize: 12,
                            color: green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    tooltip: b.extras.contains(i) ? 'Ukloni' : 'Dodaj',
                    style: IconButton.styleFrom(
                      backgroundColor: b.extras.contains(i)
                          ? green
                          : const Color(0xFFEDF2EC),
                      foregroundColor: b.extras.contains(i)
                          ? Colors.white
                          : green,
                    ),
                    onPressed: () {
                      setState(() {
                        b.extras.contains(i)
                            ? b.extras.remove(i)
                            : b.extras.add(i);
                      });
                      b.update();
                    },
                    icon: Icon(
                      b.extras.contains(i) ? Icons.check : Icons.add,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          priceSummary(b),
        ],
      ),
    );
  }
}

Widget priceSummary(Booking b) => panel(
  Column(
    children: [
      Row(
        children: [
          Expanded(
            child: small(
              'Let i tarifa · ${b.count} putnika${b.roundTrip ? ' · oba smera' : ''}',
            ),
          ),
          Text('${b.baseCost} €'),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: small('Sedišta · odlazak')),
          Text('${b.seatCost} €'),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: small('Dodatne usluge · odlazak')),
          Text('${b.extrasCost} €'),
        ],
      ),
      const Divider(height: 30),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Ukupno',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${b.total} €',
            style: const TextStyle(
              fontSize: 30,
              color: green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  ),
);
