part of '../booking_screens.dart';

class SearchScreen extends StatefulWidget {
  final Booking b;
  final bool explore;
  const SearchScreen({super.key, required this.b, this.explore = false});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Booking get b => widget.b;
  Future<void> pickDate(bool returning) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: returning
          ? b.returnDate ?? b.date.add(const Duration(days: 7))
          : b.date,
      firstDate: returning ? b.date : today,
      lastDate: today.add(const Duration(days: 730)),
      helpText: returning ? 'Datum povratka' : 'Datum polaska',
    );
    if (d == null || !mounted) return;
    setState(() {
      if (returning) {
        b.returnDate = d;
      } else {
        b.date = d;
        if (b.returnDate != null && b.returnDate!.isBefore(d)) {
          b.returnDate = null;
        }
      }
    });
    b.update();
  }

  Future<void> chooseAirport(bool origin) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading(origin ? 'Odakle putujete?' : 'Gde putujete?'),
              for (final airport in airports)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: const Icon(Icons.local_airport, color: green),
                  title: Text(airport.split(' (').first),
                  trailing: Text(
                    b.code(airport),
                    style: const TextStyle(
                      color: green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, airport),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (origin) {
        b.origin = selected;
      } else {
        b.destination = selected;
      }
    });
    b.update();
  }

  Future<void> choosePassengers() async {
    var adults = b.adults, children = b.children, infants = b.infants;
    var cabin = b.cabin;
    final applied = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text(
            'Putnici i klasa',
            style: TextStyle(
              fontFamily: 'AirVistaSerif',
              fontSize: 26,
              color: green,
            ),
          ),
          scrollable: true,
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ['Odrasli', 'Deca', 'Bebe'][i],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              small(
                                [
                                  '12 i više godina',
                                  'Od 2 do 11 godina',
                                  'Mlađi od 2 godine',
                                ][i],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Smanji: ${['Odrasli', 'Deca', 'Bebe'][i]}',
                          visualDensity: VisualDensity.compact,
                          onPressed:
                              (i == 0
                                  ? adults > 1 && adults > infants
                                  : i == 1
                                  ? children > 0
                                  : infants > 0)
                              ? () => update(() {
                                  if (i == 0) adults--;
                                  if (i == 1) children--;
                                  if (i == 2) infants--;
                                })
                              : null,
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            size: 21,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          child: Text(
                            '${[adults, children, infants][i]}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Povećaj: ${['Odrasli', 'Deca', 'Bebe'][i]}',
                          visualDensity: VisualDensity.compact,
                          onPressed:
                              adults + children + infants < 9 &&
                                  (i != 2 || infants < adults)
                              ? () => update(() {
                                  if (i == 0) adults++;
                                  if (i == 1) children++;
                                  if (i == 2) infants++;
                                })
                              : null,
                          icon: const Icon(Icons.add_circle_outline, size: 21),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 24),
                small('KLASA PUTOVANJA'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: cabin,
                  isExpanded: true,
                  items: ['Ekonomska', 'Biznis']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => cabin = value!,
                ),
                const SizedBox(height: 12),
                small('Najviše 9 putnika. Svaka beba putuje uz odraslu osobu.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Otkaži'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Potvrdi'),
            ),
          ],
        ),
      ),
    );
    if (applied != true || !mounted) return;
    setState(() {
      if (b.adults != adults ||
          b.children != children ||
          b.infants != infants) {
        b.seats.clear();
        b.passengers.clear();
      }
      b.adults = adults;
      b.children = children;
      b.infants = infants;
      b.cabin = cabin;
    });
    b.update();
  }

  Widget airportTile(bool origin) {
    final airport = origin ? b.origin : b.destination;
    return Material(
      color: const Color(0xFFF1F4EF),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: ValueKey(origin ? 'origin-picker' : 'destination-picker'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => chooseAirport(origin),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              small(origin ? 'Polazište' : 'Odredište'),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(
                    origin ? Icons.flight_takeoff : Icons.flight_land,
                    size: 18,
                    color: green,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      b.code(airport),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                airport.split(' (').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchField(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap, {
    String? subtitle,
  }) => Material(
    color: const Color(0xFFF8F9F6),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE8ECE5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: green),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: muted),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: green,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: muted),
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

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.explore)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Pronađite svoj let'),
                const Text(
                  'Izaberite rutu, datum i putnike, pa pronađite kartu za svoje putovanje.',
                  style: TextStyle(color: muted, height: 1.5),
                ),
              ],
            ),
          ),
        if (widget.explore)
          Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/plane-hero.jpg.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cream, Color(0xE6FAFAF8), Color(0x30FAFAF8)],
                      stops: [0, 0.4, 1],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00FAFAF8), Color(0x00FAFAF8), cream],
                      stops: [0, 0.65, 1],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.near_me, color: green, size: 25),
                        const SizedBox(width: 7),
                        const Expanded(
                          child: Text(
                            'AirVista',
                            style: TextStyle(
                              fontSize: 23,
                              fontFamily: 'AirVistaSerif',
                              fontWeight: FontWeight.w600,
                              color: green,
                            ),
                          ),
                        ),
                        const NotificationBell(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'VAŠE SLEDEĆE\nPOGLAVLJE POČINJE OVDE',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.8,
                        height: 1.6,
                        color: green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Gde želite\nda putujete?',
                      style: TextStyle(
                        fontFamily: 'AirVistaSerif',
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        height: 1.02,
                        color: Color(0xFF17241F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pronađite malo neba\nu svom danu.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF59655E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        if (widget.explore)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: action('Pronađi avionsku kartu', () {
              b.tab = 1;
              b.update();
            }),
          ),
        if (!widget.explore)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: panel(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3EE),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      children: [
                        for (final round in [false, true])
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: round ? 0 : 4),
                              child: Material(
                                color: b.roundTrip == round
                                    ? green
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    setState(() => b.roundTrip = round);
                                    b.update();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      round ? 'Povratno' : 'U jednom pravcu',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: b.roundTrip == round
                                            ? Colors.white
                                            : muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: airportTile(true)),
                      SizedBox(
                        width: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 44,
                          ),
                          tooltip: 'Zameni polazište i odredište',
                          onPressed: () {
                            setState(() {
                              final old = b.origin;
                              b.origin = b.destination;
                              b.destination = old;
                            });
                            b.update();
                          },
                          icon: const Icon(
                            Icons.swap_horiz,
                            size: 22,
                            color: green,
                          ),
                        ),
                      ),
                      Expanded(child: airportTile(false)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: searchField(
                            'Polazak',
                            b.dateLabel,
                            Icons.calendar_today_outlined,
                            () => pickDate(false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: searchField(
                            'Putnici i klasa',
                            '${b.count} ${b.count == 1 ? 'putnik' : 'putnika'}',
                            Icons.person_outline,
                            choosePassengers,
                            subtitle: b.cabin,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (b.roundTrip) ...[
                    const SizedBox(height: 10),
                    searchField(
                      'Povratak',
                      b.returnDate == null
                          ? 'Izaberite datum'
                          : '${b.returnDate!.day}.${b.returnDate!.month}.${b.returnDate!.year}.',
                      Icons.event_outlined,
                      () => pickDate(true),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (b.origin == b.destination) {
                          message(
                            context,
                            'Izaberite različito polazište i odredište.',
                          );
                          return;
                        }
                        if (b.roundTrip && b.returnDate == null) {
                          message(context, 'Izaberite datum povratka.');
                          return;
                        }
                        b.reference = null;
                        b.bookedTotal = null;
                        b.status = 'Potvrđena';
                        open(context, ResultsScreen(b: b));
                      },
                      icon: const Icon(Icons.search, size: 19),
                      label: const Text(
                        'Pretraži letove',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (widget.explore)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Popularne destinacije',
                  style: TextStyle(
                    fontFamily: 'AirVistaSerif',
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: green,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => open(context, const CitiesScreen()),
                    child: const Text('View all'),
                  ),
                ),
                SizedBox(
                  height: 190,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final city in cities.take(6)) destination(city),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
  Widget destination(City city) => Padding(
    padding: const EdgeInsets.only(right: 14),
    child: SizedBox(
      width: 156,
      child: InkWell(
        onTap: () => open(context, CityDetailsScreen(city: city)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CityImage(city),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xB3000000)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontFamily: 'AirVistaSerif',
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      city.country,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
