part of '../booking_screens.dart';

enum _TripFilter {
  upcoming('Predstojeća', 'Vaša sledeća avantura vas čeka.'),
  past('Prošla', 'Još nemate prošlih putovanja.'),
  cancelled('Otkazana', 'Nemate otkazanih putovanja.');

  const _TripFilter(this.label, this.emptyTitle);

  final String label;
  final String emptyTitle;

  static _TripFilter forBooking(Booking booking, DateTime today) {
    if (booking.status == 'Otkazana') return cancelled;
    final lastFlight = booking.roundTrip
        ? booking.returnDate ?? booking.date
        : booking.date;
    return DateUtils.dateOnly(lastFlight).isBefore(today) ? past : upcoming;
  }
}

class TripsScreen extends StatefulWidget {
  final Booking b;
  final VoidCallback onFindFlight;

  const TripsScreen({super.key, required this.b, required this.onFindFlight});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  static const _surface = Color(0xFFFCFBF6);
  static const _accent = Color(0xFFE5EDE4);
  static const _secondaryText = Color(0xFF59655E);
  _TripFilter _filter = _TripFilter.upcoming;

  @override
  Widget build(BuildContext context) {
    if (AuthService.currentUser == null) {
      return const GuestSignIn(
        message: 'Prijavi se ili se registruj da vidiš svoja putovanja i rezervišeš let.',
      );
    }

    final saved = NotificationService.instance.myBookings;
    final booking = widget.b;
    final trips = saved.isEmpty && booking.reference != null
        ? [booking]
        : saved;
    final today = DateUtils.dateOnly(DateTime.now());
    final visibleTrips = trips
        .where((trip) => _TripFilter.forBooking(trip, today) == _filter)
        .toList();

    return ColoredBox(
      color: const Color(0xFFF4F2E9),
      child: SizedBox.expand(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Vaša putovanja',
                      style: TextStyle(
                        color: green,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _badge(
                    Text(
                      '${trips.length}',
                      semanticsLabel: 'Ukupan broj rezervacija ${trips.length}',
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE8DE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    for (final filter in _TripFilter.values)
                      Expanded(
                        child: Semantics(
                          selected: filter == _filter,
                          child: TextButton(
                            onPressed: () => setState(() => _filter = filter),
                            style: TextButton.styleFrom(
                              foregroundColor: filter == _filter
                                  ? green
                                  : _secondaryText,
                              backgroundColor: filter == _filter
                                  ? _surface
                                  : null,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              filter.label,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (visibleTrips.isEmpty) _emptyState(),
              for (final trip in visibleTrips) ...[
                reservationCard(trip),
                spaced(
                  action(
                    'Pregledaj rezervaciju',
                    () => open(context, ReservationScreen(b: trip)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Savet za putovanje',
                style: TextStyle(
                  color: green,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _card(
                const Row(
                  children: [
                    Icon(Icons.schedule, color: green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Za kraće letove dođite na aerodrom najmanje dva sata ranije.',
                        style: TextStyle(color: _secondaryText, height: 1.5),
                      ),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Center(child: _badge(const Icon(Icons.luggage_outlined, color: green))),
        const SizedBox(height: 16),
        Text(
          _filter.emptyTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: green,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (_filter == _TripFilter.upcoming) ...[
          const SizedBox(height: 10),
          const Text(
            'Kada rezervišete let, detalji putovanja pojaviće se ovde.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText, height: 1.5),
          ),
          const SizedBox(height: 36),
          FilledButton.icon(
            onPressed: widget.onFindFlight,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF305544),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 56),
            ),
            icon: const Icon(Icons.search),
            label: const Text('Pronađi let'),
          ),
        ] else
          const SizedBox(height: 26),
      ],
    ),
    padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
  );

  Widget _badge(Widget child) => Container(
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    padding: const EdgeInsets.all(12),
    decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
    child: Align(widthFactor: 1, heightFactor: 1, child: child),
  );

  Widget _card(Widget child, {required EdgeInsets padding}) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: _surface,
      border: Border.all(color: const Color(0xFFDFDDD1)),
      borderRadius: BorderRadius.circular(24),
    ),
    child: child,
  );
}
