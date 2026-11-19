part of '../booking_screens.dart';

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
    listenable: Listenable.merge([
      b,
      CatalogService.instance,
      NotificationService.instance,
    ]),
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: tab == 3
                ? ProfileScreen(onBack: () => selectTab(0))
                : tab == 2
                ? TripsScreen(b: b, onFindFlight: () => selectTab(1))
                : SearchScreen(b: b, explore: tab == 0, key: ValueKey(tab)),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: selectTab,
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

  void selectTab(int index) {
    b.tab = index;
    b.update();
  }
}
