part of '../booking_screens.dart';

class SeatsScreen extends StatefulWidget {
  final Booking b;
  const SeatsScreen({super.key, required this.b});
  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  int passenger = 0;
  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    return BookingPage(
      b: b,
      title: 'Izaberite sedište',
      step: 4,
      bottom: action('Nastavi', () {
        if (b.seats.length != b.seatCount) {
          message(context, 'Izaberite sedište za svakog putnika.');
          return;
        }
        open(context, ExtrasScreen(b: b));
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          spaced(
            small(
              '${b.route} · ${b.flight.number}\n${b.dateLabel} · ${b.flight.departure}',
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              legend('Slobodno', const Color(0xFFEDF0EB)),
              legend('Izabrano', green),
              legend('Zauzeto', const Color(0xFFD4D0C6)),
              legend('Više prostora · 15 €', const Color(0xFFCBE2DB)),
            ],
          ),
          const SizedBox(height: 20),
          spaced(
            DropdownButtonFormField<int>(
              initialValue: passenger,
              decoration: const InputDecoration(labelText: 'Putnik'),
              items: List.generate(
                b.seatCount,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    '${b.passengers[i]['first']} ${b.passengers[i]['last']}',
                  ),
                ),
              ),
              onChanged: (v) => setState(() => passenger = v!),
            ),
          ),
          panel(
            Column(
              children: [
                const Icon(Icons.flight, size: 45, color: muted),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 26),
                    for (final col in ['A', 'B', 'C', '', 'D', 'E', 'F'])
                      Expanded(child: Center(child: small(col))),
                  ],
                ),
                const SizedBox(height: 8),
                for (int row = 1; row <= (b.flight.capacity / 6).ceil(); row++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        SizedBox(width: 26, child: small('$row')),
                        for (final col in ['A', 'B', 'C', '', 'D', 'E', 'F'])
                          Expanded(
                            child: col.isEmpty
                                ? const SizedBox()
                                : seat(b, '$row$col', row),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sedište ${b.seats[passenger] ?? '—'}',
                  style: const TextStyle(
                    fontFamily: 'AirVistaSerif',
                    fontSize: 24,
                  ),
                ),
                small(
                  RegExp(r'^1[A-F]$').hasMatch(b.seats[passenger] ?? '')
                      ? 'Dodatni prostor za noge · 15 €'
                      : 'Standardno sedište · bez doplate',
                ),
                small('${b.seats.length} od ${b.seatCount} sedišta izabrano'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget legend(String text, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
      small(text),
    ],
  );
  Widget seat(Booking b, String id, int row) {
    final selected = b.seats.containsValue(id),
        taken =
            NotificationService.instance.occupiedSeats(b).contains(id) ||
            (row - 1) * 6 + id.codeUnitAt(id.length - 1) - 64 >
                b.flight.capacity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        label: 'Sedište $id${taken ? ', zauzeto' : ''}',
        selected: selected,
        child: InkWell(
          onTap: taken
              ? null
              : () {
                  if (selected && b.seats[passenger] != id) {
                    message(
                      context,
                      'Sedište je već izabrano za drugog putnika.',
                    );
                    return;
                  }
                  setState(() => b.seats[passenger] = id);
                  b.update();
                },
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: selected
                  ? green
                  : taken
                  ? const Color(0xFFD4D0C6)
                  : row == 1
                  ? const Color(0xFFCBE2DB)
                  : const Color(0xFFEDF0EB),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : taken
                  ? const Icon(Icons.close, size: 12, color: muted)
                  : Text(
                      id,
                      style: const TextStyle(fontSize: 10, color: green),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
