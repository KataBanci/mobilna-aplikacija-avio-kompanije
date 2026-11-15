import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/city.dart';
import 'cities_screen.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

const green = Color(0xFF244638);
const cream = Color(0xFFFAFAF8);
const muted = Color(0xFF7C837E);
const airports = [
  'Beograd (BEG)',
  'Rim (FCO)',
  'Pariz (CDG)',
  'London (LHR)',
  'Beč (VIE)',
];
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

class BookingHome extends StatefulWidget {
  const BookingHome({super.key});
  @override
  State<BookingHome> createState() => _BookingHomeState();
}

void goHome(BuildContext context, Booking b, [int tab = 0]) {
  b.tab = tab;
  b.update();
  Navigator.of(context)
      .popUntil((r) => r.isFirst || r.settings.name == '/booking');
}

String? validatePhone(String value) {
  if (!RegExp(r'\d').hasMatch(value) ||
      !RegExp(r'^\+?[0-9\s()./-]+$').hasMatch(value)) {
    return 'Unesite broj telefona.';
  }
  return null;
}

class _BookingHomeState extends State<BookingHome> {
  final b = Booking();
  int get tab => b.tab;
  @override
  void dispose() {
    b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: b,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: tab == 3
                ? const ProfileScreen()
                : tab == 2
                ? TripsScreen(b: b)
                : SearchScreen(b: b, explore: tab == 0, key: ValueKey(tab)),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) {
          b.tab = i;
          b.update();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'Istraži',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Pretraga'),
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
    ),
  );
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
  Widget build(BuildContext context) => Scaffold(
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
        NavigationDestination(icon: Icon(Icons.search), label: 'Pretraga'),
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
                Row(
                  children: [
                    Expanded(child: heading('Pronađite svoj let')),
                    const NotificationBell(),
                  ],
                ),
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
                      destination('Rim', 'Italija', 'rome.jpg'),
                      destination('Pariz', 'Francuska', 'Paris.jpg'),
                      destination('London', 'Velika Britanija', 'london.jpg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
  Widget destination(String city, String country, String image) => Padding(
    padding: const EdgeInsets.only(right: 14),
    child: SizedBox(
      width: 156,
      child: InkWell(
        onTap: () => open(
          context,
          CityDetailsScreen(
            city: cities.firstWhere((destination) => destination.name == city),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/$image', fit: BoxFit.cover),
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
                      city,
                      style: const TextStyle(
                        fontFamily: 'AirVistaSerif',
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      country,
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
      bottom: action('Nastavi', () => open(context, PassengerScreen(b: b))),
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
                  '${b.flight.number} · Airbus A319\nLični predmet do 4 kg uključen.\nRučni prtljag do 8 kg prema izabranoj tarifi.',
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

class PassengerScreen extends StatefulWidget {
  final Booking b;
  const PassengerScreen({super.key, required this.b});
  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  final form = GlobalKey<FormState>();
  late final List<Map<String, String>> data;
  @override
  void initState() {
    super.initState();
    data = List.generate(
      widget.b.count,
      (i) => i < widget.b.passengers.length
          ? Map.of(widget.b.passengers[i])
          : <String, String>{},
    );
  }

  String type(int i) => i < widget.b.adults
      ? 'Odrasla osoba'
      : i < widget.b.adults + widget.b.children
      ? 'Dete'
      : 'Beba';
  Widget field(
    int i,
    String label,
    String key, {
    String? hint,
    TextInputType? keyboard,
    String? Function(String)? validate,
  }) => spaced(
    labeledField(
      label,
      TextFormField(
        initialValue: data[i][key],
        decoration: InputDecoration(hintText: hint),
        keyboardType: keyboard,
        onSaved: (v) => data[i][key] = v!.trim(),
        validator: (v) => v == null || v.trim().isEmpty
            ? 'Unesite ${label.toLowerCase()}.'
            : validate?.call(v.trim()),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => BookingPage(
    b: widget.b,
    title: 'Podaci o putnicima',
    step: 3,
    bottom: action('Nastavi na izbor sedišta', () {
      if (form.currentState!.validate()) {
        form.currentState!.save();
        widget.b.passengers
          ..clear()
          ..addAll(data);
        widget.b.update();
        open(context, SeatsScreen(b: widget.b));
      }
    }),
    child: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          spaced(
            small(
              'Unesite podatke tačno kao u pasošu. Vrsta putnika izabrana je u pretrazi. Bebe putuju u krilu odrasle osobe.',
            ),
          ),
          for (int i = 0; i < data.length; i++)
            panel(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Putnik ${i + 1}',
                    style: const TextStyle(
                      fontFamily: 'AirVistaSerif',
                      fontSize: 23,
                    ),
                  ),
                  spaced(small(type(i))),
                  field(i, 'Ime', 'first', hint: 'Marko'),
                  field(i, 'Prezime', 'last', hint: 'Petrović'),
                  spaced(
                    FormField<String>(
                      validator: (_) {
                        final birth = DateTime.tryParse(
                          data[i]['birthIso'] ?? '',
                        );
                        if (birth == null) return 'Izaberite datum rođenja.';
                        final travel = widget.b.date;
                        var age = travel.year - birth.year;
                        if (travel.month < birth.month ||
                            (travel.month == birth.month &&
                                travel.day < birth.day)) {
                          age--;
                        }
                        if ((type(i) == 'Odrasla osoba' && age < 12) ||
                            (type(i) == 'Dete' && (age < 2 || age >= 12)) ||
                            (type(i) == 'Beba' && age >= 2)) {
                          return 'Uzrast ne odgovara vrsti putnika.';
                        }
                        return null;
                      },
                      builder: (state) => labeledField(
                        'Datum rođenja',
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            final now = DateTime.now();
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.tryParse(
                                    data[i]['birthIso'] ?? '',
                                  ) ??
                                  DateTime(1995, 6, 15),
                              firstDate: DateTime(1920),
                              lastDate: now,
                              helpText: 'Datum rođenja',
                            );
                            if (date != null && mounted) {
                              setState(() {
                                data[i]['birth'] =
                                    '${date.day}.${date.month}.${date.year}.';
                                data[i]['birthIso'] = date.toIso8601String();
                              });
                              state.didChange(data[i]['birth']);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              errorText: state.errorText,
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                              ),
                            ),
                            child: Text(
                              data[i]['birth'] ?? 'Izaberite datum',
                              style: TextStyle(
                                fontSize: 14,
                                color: data[i]['birth'] == null ? muted : green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  spaced(
                    labeledField(
                      'Državljanstvo',
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: data[i]['nationality'] ?? 'Srbija',
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.public_outlined,
                            size: 19,
                            color: green,
                          ),
                        ),
                        items:
                            [
                                  'Srbija',
                                  'Crna Gora',
                                  'Bosna i Hercegovina',
                                  'Hrvatska',
                                  'Severna Makedonija',
                                  'Italija',
                                  'Nemačka',
                                ]
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => data[i]['nationality'] = v!,
                        onSaved: (v) => data[i]['nationality'] = v!,
                      ),
                    ),
                  ),
                  field(
                    i,
                    'Broj pasoša',
                    'passport',
                    hint: '012345678',
                    validate: (v) => RegExp(r'^[a-zA-Z0-9]{6,12}$').hasMatch(v)
                        ? null
                        : 'Unesite 6–12 slova ili cifara.',
                  ),
                  if (i == 0) ...[
                    field(
                      i,
                      'Adresa elektronske pošte',
                      'email',
                      hint: 'marko.petrovic@primer.rs',
                      keyboard: TextInputType.emailAddress,
                      validate: (v) =>
                          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)
                          ? null
                          : 'Unesite ispravnu adresu.',
                    ),
                    field(
                      i,
                      'Broj telefona',
                      'phone',
                      hint: '064 123 4567',
                      keyboard: TextInputType.phone,
                      validate: validatePhone,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class SeatsScreen extends StatefulWidget {
  final Booking b;
  const SeatsScreen({super.key, required this.b});
  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  int passenger = 0;
  final occupied = {
    '2A',
    '2B',
    '3F',
    '4A',
    '5C',
    '6D',
    '7E',
    '8B',
    '9A',
    '10F',
  };
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
                for (int row = 1; row <= 10; row++)
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
    final selected = b.seats.containsValue(id), taken = occupied.contains(id);
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

class PaymentScreen extends StatefulWidget {
  final Booking b;
  const PaymentScreen({super.key, required this.b});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final form = GlobalKey<FormState>();
  bool accepted = false;
  String method = 'Platna kartica';
  bool luhn(String input) {
    final v = input.replaceAll(' ', '');
    if (!RegExp(r'^\d{13,19}$').hasMatch(v)) return false;
    int sum = 0;
    bool doubleDigit = false;
    for (int i = v.length - 1; i >= 0; i--) {
      int n = int.parse(v[i]);
      if (doubleDigit) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      doubleDigit = !doubleDigit;
    }
    return sum % 10 == 0;
  }

  Widget input(
    String label,
    String? Function(String) validate, {
    TextInputType? keyboard,
    bool secret = false,
  }) => spaced(
    labeledField(
      label,
      TextFormField(
        decoration: const InputDecoration(),
        keyboardType: keyboard,
        obscureText: secret,
        validator: (v) => validate(v?.trim() ?? ''),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final b = widget.b;
    return BookingPage(
      b: b,
      title: 'Plaćanje',
      step: 6,
      bottom: action('Plati · ${b.total} €', () {
        if (!form.currentState!.validate()) return;
        if (!accepted) {
          message(context, 'Potvrdite demonstracionu rezervaciju.');
          return;
        }
        b.reference ??=
            'AV${DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase()}';
        NotificationService.instance.confirmBooking(b);
        b.update();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => ConfirmationScreen(b: b)),
          (route) => route.isFirst || route.settings.name == '/booking',
        );
      }),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            panel(
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, color: green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Demonstraciono plaćanje\nNema naplate. Koristite isključivo probne podatke.',
                      style: TextStyle(color: green, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Izaberite način plaćanja',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            panel(
              Column(
                children: [
                  for (final entry in [
                    'Platna kartica',
                    'PayPal',
                    'Apple Pay',
                    'Google Pay',
                  ].asMap().entries) ...[
                    if (entry.key > 0) const SizedBox(height: 8),
                    Semantics(
                      selected: method == entry.value,
                      button: true,
                      child: Material(
                        color: method == entry.value
                            ? const Color(0xFFEEF4ED)
                            : const Color(0xFFFAFBF8),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => method = entry.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: method == entry.value
                                    ? green
                                    : const Color(0xFFE7EBE3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  [
                                    Icons.credit_card_outlined,
                                    Icons.account_balance_wallet_outlined,
                                    Icons.apple,
                                    Icons.account_balance_wallet_outlined,
                                  ][entry.key],
                                  size: 22,
                                  color: green,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  method == entry.value
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 20,
                                  color: method == entry.value ? green : muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (method == 'Platna kartica')
              panel(
                Column(
                  children: [
                    small('Probni broj: 4242 4242 4242 4242'),
                    const SizedBox(height: 12),
                    input(
                      'Broj kartice',
                      (v) => luhn(v)
                          ? null
                          : 'Unesite ispravan probni broj kartice.',
                      keyboard: TextInputType.number,
                    ),
                    input('Datum isteka (MM/GG)', (v) {
                      final match = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$')
                          .firstMatch(v);
                      if (match == null) return 'Koristite format MM/GG.';
                      final end = DateTime(
                        2000 + int.parse(match[2]!),
                        int.parse(match[1]!) + 1,
                      );
                      return end.isAfter(DateTime.now())
                          ? null
                          : 'Kartica je istekla.';
                    }, keyboard: TextInputType.datetime),
                    input(
                      'CVV sigurnosni kod',
                      (v) => RegExp(r'^\d{3,4}$').hasMatch(v)
                          ? null
                          : 'Unesite 3 ili 4 cifre.',
                      keyboard: TextInputType.number,
                      secret: true,
                    ),
                    input(
                      'Ime i prezime vlasnika kartice',
                      (v) => v.split(' ').where((s) => s.isNotEmpty).length >= 2
                          ? null
                          : 'Unesite ime i prezime.',
                    ),
                  ],
                ),
              )
            else
              panel(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 19,
                      color: green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$method je izabran',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          small(
                            'Probno plaćanje bez naplate. Nastavite dugmetom „Plati“.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            priceSummary(b),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              onChanged: (v) => setState(() => accepted = v!),
              title: const Text(
                'Razumem da je ovo demonstraciona rezervacija.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              child: Icon(Icons.flight_takeoff, color: Colors.white, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Rezervacija je potvrđena!',
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
          'Vaše putovanje u ${b.destination.split(' (').first} je spremno.',
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
        OutlinedButton.icon(
          onPressed: () async {
            try {
              final result = await exportCalendar(b);
              if (!context.mounted) return;
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Dodavanje u kalendar'),
                  content: SelectableText(result),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Zatvori'),
                    ),
                  ],
                ),
              );
            } catch (_) {
              if (context.mounted) {
                message(context, 'Izvoz nije uspeo. Pokušajte ponovo.');
              }
            }
          },
          icon: const Icon(Icons.event_outlined),
          label: const Text('Dodaj u kalendar'),
        ),
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
          const Expanded(
            child: Text(
              'Potvrđena rezervacija',
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

class TripsScreen extends StatelessWidget {
  final Booking b;
  const TripsScreen({super.key, required this.b});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading('Vaša putovanja'),
        if (b.reference != null) ...[
          reservationCard(b),
          action(
            'Pregledaj rezervaciju',
            () => open(context, ConfirmationScreen(b: b)),
          ),
        ] else
          panel(
            const Column(
              children: [
                Icon(Icons.airplane_ticket_outlined, size: 48, color: green),
                SizedBox(height: 16),
                Text('Vaša sledeća avantura vas čeka.'),
                SizedBox(height: 8),
                Text(
                  'Rezervisana putovanja pojaviće se ovde.',
                  style: TextStyle(color: muted),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
