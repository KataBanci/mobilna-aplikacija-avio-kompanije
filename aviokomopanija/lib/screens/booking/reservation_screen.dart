part of '../booking_screens.dart';

class ReservationScreen extends StatelessWidget {
  final Booking b;
  const ReservationScreen({super.key, required this.b});
  @override
  Widget build(BuildContext context) => BookingPage(
    b: b,
    title: 'Vaša rezervacija',
    step: 7,
    bottom: action('Nazad na početnu', () => goHome(context, b)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        spaced(small('Sve za vaše putovanje, na jednom mestu.')),
        if (b.flightStatus != null) spaced(Text(b.flightStatus!)),
        reservationCard(b),
        const SizedBox(height: 4),
        const Text(
          'Putnici i sedišta',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: green,
          ),
        ),
        const SizedBox(height: 12),
        panel(
          Column(
            children: [
              for (int i = 0; i < b.passengers.length; i++) ...[
                if (i > 0) const Divider(height: 24),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${b.passengers[i]['first']} ${b.passengers[i]['last']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          small(
                            b.seats[i] == null
                                ? 'Beba · u krilu odrasle osobe'
                                : 'Putnik ${i + 1} · sedište ${b.seats[i]}',
                          ),
                        ],
                      ),
                    ),
                    if (b.seats[i] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4EF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          b.seats[i]!,
                          style: const TextStyle(
                            color: green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pregled troškova',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: green,
          ),
        ),
        const SizedBox(height: 12),
        priceSummary(b),
        TextButton.icon(
          onPressed: () => goHome(context, b, 2),
          icon: const Icon(Icons.airplane_ticket_outlined, size: 18),
          label: const Text('Moja putovanja'),
        ),
      ],
    ),
  );
}

Widget reservationCard(Booking b) => panel(
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const Icon(Icons.verified_outlined, size: 18, color: green),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '${b.status} rezervacija',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: green,
              ),
            ),
          ),
          Flexible(
            child: Text(
              b.reference ?? '',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 11,
                color: muted,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
      const Divider(height: 28, color: Color(0xFFE8EBE5)),
      Row(
        children: [
          Expanded(child: _airportSummary(b, b.origin, false)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.flight_takeoff, color: green, size: 24),
          ),
          Expanded(child: _airportSummary(b, b.destination, true)),
        ],
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 15, color: green),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                b.dateLabel,
                style: const TextStyle(fontSize: 12, color: green),
              ),
            ),
            const Icon(Icons.person_outline, size: 16, color: green),
            const SizedBox(width: 5),
            Text(
              '${b.count} ${b.count == 1
                  ? 'putnik'
                  : b.count < 5
                  ? 'putnika'
                  : 'putnika'}',
              style: const TextStyle(fontSize: 12, color: green),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          const Icon(Icons.flight, color: green, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              b.flight.airline,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${b.flight.departure}  →  ${b.flight.arrival}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      const SizedBox(height: 5),
      small(
        '${b.flight.number} · ${b.flight.duration} · ${b.flight.direct ? 'Direktan let' : '1 presedanje'}',
      ),
      const SizedBox(height: 5),
      small('${['Osnovni', 'Standardni', 'Fleksibilni'][b.fare]} · ${b.cabin}'),
      if (b.roundTrip) ...[
        const Divider(height: 24, color: Color(0xFFE8EBE5)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.sync_alt, size: 17, color: green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Povratni let',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: green,
                    ),
                  ),
                  small(
                    '${b.returnDate!.day}.${b.returnDate!.month}.${b.returnDate!.year}. · ${b.code(b.destination)} → ${b.code(b.origin)}',
                  ),
                  small(
                    '${b.flight.departure} – ${b.flight.arrival} · probni raspored',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ],
  ),
);
Widget _airportSummary(Booking b, String airport, bool right) => Column(
  crossAxisAlignment: right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
  children: [
    Text(
      b.code(airport),
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: green,
        letterSpacing: 1,
      ),
    ),
    small(airport.split(' (').first),
  ],
);
