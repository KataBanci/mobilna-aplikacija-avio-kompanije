part of '../booking_screens.dart';

class ResultsScreen extends StatefulWidget {
  final Booking b;
  const ResultsScreen({super.key, required this.b});
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool direct = false, cheap = false;
  String airline = 'Sve aviokompanije', sort = 'Najniža cena';
  late final DateTime firstDate = widget.b.date;
  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    final result =
        flights
            .where(
              (f) =>
                  (!direct || f.direct) &&
                  f.origin == b.origin &&
                  f.destination == b.destination &&
                  (f.date == null || DateUtils.isSameDay(f.date, b.date)) &&
                  f.status != 'Otkazan' &&
                  f.status != 'Završen' &&
                  NotificationService.instance.availableSeats(f, b.date) >=
                      b.seatCount &&
                  (!cheap || f.price <= 110) &&
                  (airline == 'Sve aviokompanije' || f.airline == airline),
            )
            .toList()
          ..sort(
            (a, c) => sort == 'Najniža cena'
                ? a.price.compareTo(c.price)
                : a.departure.compareTo(c.departure),
          );
    return BookingPage(
      b: b,
      title: b.route,
      step: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          small('${b.dateLabel} · ${b.count} putnika · ${b.cabin}'),
          if (b.roundTrip)
            spaced(
              small(
                'Povratak: ${b.returnDate!.day}.${b.returnDate!.month}.${b.returnDate!.year}. · Probna povratna karta uključuje obrnutu rutu po istoj tarifi.',
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final d = firstDate.add(Duration(days: i));
                final selected = DateUtils.isSameDay(b.date, d);
                return InkWell(
                  onTap: () {
                    if (b.returnDate != null && b.returnDate!.isBefore(d)) {
                      message(context, 'Polazak mora biti pre povratka.');
                      return;
                    }
                    setState(() => b.date = d);
                    b.update();
                  },
                  child: Container(
                    width: 77,
                    decoration: BoxDecoration(
                      color: selected ? green : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${d.day}.${d.month}.',
                          style: TextStyle(
                            color: selected ? Colors.white70 : muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'od 89 €',
                          style: TextStyle(
                            color: selected ? Colors.white : green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          panel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 19, color: green),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Filteri',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: green,
                        ),
                      ),
                    ),
                    if (direct || cheap || airline != 'Sve aviokompanije')
                      TextButton(
                        onPressed: () => setState(() {
                          direct = false;
                          cheap = false;
                          airline = 'Sve aviokompanije';
                        }),
                        child: const Text(
                          'Poništi',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text(
                        'Bez presedanja',
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: direct,
                      onSelected: (v) => setState(() => direct = v),
                      selectedColor: const Color(0xFFE7EFE7),
                      backgroundColor: const Color(0xFFF7F9F5),
                      side: BorderSide(
                        color: direct ? green : const Color(0xFFE2E8DF),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                    ),
                    FilterChip(
                      label: const Text(
                        'Do 110 €',
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: cheap,
                      onSelected: (v) => setState(() => cheap = v),
                      selectedColor: const Color(0xFFE7EFE7),
                      backgroundColor: const Color(0xFFF7F9F5),
                      side: BorderSide(
                        color: cheap ? green : const Color(0xFFE2E8DF),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                labeledField(
                  'Aviokompanija',
                  DropdownButtonFormField<String>(
                    key: ValueKey(airline),
                    isExpanded: true,
                    initialValue: airline,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontSize: 14, color: green),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.flight_outlined,
                        size: 19,
                        color: green,
                      ),
                    ),
                    items:
                        ['Sve aviokompanije', ...flights.map((f) => f.airline)]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => airline = v!),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(child: small('${result.length} dostupnih letova')),
              DropdownButton<String>(
                value: sort,
                underline: const SizedBox(),
                items: ['Najniža cena', 'Vreme polaska']
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => sort = v!),
              ),
            ],
          ),
          small('Demonstracioni red letenja i cene.'),
          const SizedBox(height: 12),
          if (result.isEmpty)
            panel(
              const Text(
                'Nema letova za izabrane filtere. Promenite kriterijume.',
              ),
            ),
          for (final f in result)
            InkWell(
              onTap: () {
                b.flight = f;
                b.fare = 0;
                b.update();
                open(context, DetailsScreen(b: b));
              },
              child: panel(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: cream,
                          child: Icon(Icons.flight, color: green),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            f.airline,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sačuvaj let',
                          onPressed: () => setState(() {
                            b.favorites.contains(f.number)
                                ? b.favorites.remove(f.number)
                                : b.favorites.add(f.number);
                          }),
                          icon: Icon(
                            b.favorites.contains(f.number)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    flightTimes(b, f),
                    small(
                      '${f.status} · Slobodna sedišta: ${NotificationService.instance.availableSeats(f, b.date)}',
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: f.price == 89
                              ? const Text(
                                  'Najbolja cena',
                                  style: TextStyle(color: green, fontSize: 12),
                                )
                              : small('Cena po putniku'),
                        ),
                        Text(
                          '${f.price} €',
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            color: green,
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget flightTimes(Booking b, Flight f) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          f.departure,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        small(b.code(b.origin)),
      ],
    ),
    Flexible(
      child: Column(
        children: [
          small(f.duration),
          const SizedBox(
            width: 100,
            child: Row(
              children: [
                Expanded(child: Divider()),
                Icon(Icons.flight, size: 18, color: green),
                Expanded(child: Divider()),
              ],
            ),
          ),
          small(f.direct ? 'Direktan' : '1 presedanje'),
        ],
      ),
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          f.arrival,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
        small(b.code(b.destination)),
      ],
    ),
  ],
);
