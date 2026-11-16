import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../models/city.dart';
import '../../services/auth_service.dart';
import '../../services/catalog_service.dart';
import '../../services/notification_service.dart';
import '../cities_screen.dart';
import '../booking_screens.dart' show ReservationScreen;

const flightStatuses = ['Zakazan', 'Odložen', 'Otkazan', 'Završen'];
void adminOpen(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
void adminMessage(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
Future<bool> confirmAdmin(
  BuildContext context,
  String title,
  String text,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Potvrdi'),
          ),
        ],
      ),
    ) ??
    false;

class AdminPage extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const AdminPage({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });
  @override
  Widget build(BuildContext context) => AuthService.isAdmin
      ? Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: child,
            ),
          ),
          floatingActionButton: action,
        )
      : const Scaffold(
          body: Center(
            child: Text('Pristup je dozvoljen samo administratoru.'),
          ),
        );
}

class AdminFlightsScreen extends StatefulWidget {
  const AdminFlightsScreen({super.key});
  @override
  State<AdminFlightsScreen> createState() => _AdminFlightsScreenState();
}

class _AdminFlightsScreenState extends State<AdminFlightsScreen> {
  String query = '', status = 'Svi statusi';
  @override
  Widget build(BuildContext context) => AdminPage(
    title: 'Upravljanje letovima',
    action: FloatingActionButton.extended(
      onPressed: () => adminOpen(context, const FlightEditor()),
      icon: const Icon(Icons.add),
      label: const Text('Dodaj let'),
    ),
    child: ListenableBuilder(
      listenable: CatalogService.instance,
      builder: (context, _) {
        final result = flights
            .where(
              (f) =>
                  (status == 'Svi statusi' || f.status == status) &&
                  '${f.number} ${f.airline} ${f.origin} ${f.destination}'
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Pretraži letove',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: status,
              items: [
                'Svi statusi',
                ...flightStatuses,
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => status = v!),
            ),
            const SizedBox(height: 16),
            if (result.isEmpty) const Text('Nema letova za izabranu pretragu.'),
            for (final f in result)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${f.number} · ${f.origin} → ${f.destination}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${f.status} · ${f.date == null ? 'Svakodnevni raspored' : dateInput(f.date!)} · ${f.departure}–${f.arrival}',
                      ),
                      Text(
                        '${f.airline} · ${f.aircraft} · ${f.capacity} sedišta · ${f.price} €',
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                adminOpen(context, FlightEditor(flight: f)),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Izmeni'),
                          ),
                          TextButton.icon(
                            onPressed:
                                f.status == 'Otkazan' || f.status == 'Završen'
                                ? null
                                : () async {
                                    if (!await confirmAdmin(
                                      context,
                                      'Otkaži let',
                                      'Otkazati let ${f.number}? Putnici će dobiti obaveštenje, a njihove rezervacije biće otkazane.',
                                    )) {
                                      return;
                                    }
                                    CatalogService.instance.saveFlight(
                                      copyFlight(f, status: 'Otkazan'),
                                      previous: f,
                                    );
                                  },
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Otkaži'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

String dateInput(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
DateTime? parseDate(String value) {
  final date = DateTime.tryParse(value);
  return date != null && dateInput(date) == value ? date : null;
}

Flight copyFlight(Flight f, {String? status}) => Flight(
  f.airline,
  f.departure,
  f.arrival,
  f.duration,
  f.number,
  f.price,
  f.direct,
  origin: f.origin,
  destination: f.destination,
  date: f.date,
  arrivalDate: f.arrivalDate,
  aircraft: f.aircraft,
  capacity: f.capacity,
  status: status ?? f.status,
);

// Shared editor keeps long forms scrollable on phone and desktop.
class AdminFields {
  final Map<String, TextEditingController> controllers;
  AdminFields(Map<String, String> values)
    : controllers = values.map(
        (key, value) => MapEntry(key, TextEditingController(text: value)),
      );
  String value(String key) => controllers[key]!.text.trim();
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
  }

  Widget field(
    String key,
    String label, {
    bool required = true,
    int lines = 1,
    String? Function(String)? validate,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controllers[key],
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: lines > 1,
      ),
      validator: (v) => required && (v?.trim().isEmpty ?? true)
          ? 'Obavezno polje.'
          : validate?.call(v?.trim() ?? ''),
    ),
  );
}

class FlightEditor extends StatefulWidget {
  final Flight? flight;
  const FlightEditor({super.key, this.flight});
  @override
  State<FlightEditor> createState() => _FlightEditorState();
}

class _FlightEditorState extends State<FlightEditor> {
  final form = GlobalKey<FormState>();
  late AdminFields fields;
  late String status;
  late bool direct;
  late bool recurring;
  @override
  void initState() {
    super.initState();
    final f = widget.flight;
    status = f?.status ?? 'Zakazan';
    direct = f?.direct ?? true;
    recurring = f != null && f.date == null;
    fields = AdminFields({
      'number': f?.number ?? '',
      'airline': f?.airline ?? '',
      'origin': f?.origin ?? '',
      'destination': f?.destination ?? '',
      'date': dateInput(
        f?.date ?? DateTime.now().add(const Duration(days: 14)),
      ),
      'arrivalDate': dateInput(
        f?.arrivalDate ??
            f?.date ??
            DateTime.now().add(const Duration(days: 14)),
      ),
      'departure': f?.departure ?? '',
      'arrival': f?.arrival ?? '',
      'aircraft': f?.aircraft ?? '',
      'capacity': '${f?.capacity ?? 180}',
      'price': '${f?.price ?? 89}',
    });
  }

  @override
  void dispose() {
    fields.dispose();
    super.dispose();
  }

  String? timeError(String v) =>
      RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(v)
      ? null
      : 'Format HH:mm, npr. 08:20.';
  String? dateError(String v) =>
      parseDate(v) == null ? 'Format GGGG-MM-DD, npr. 2026-12-31.' : null;
  @override
  Widget build(BuildContext context) => AdminPage(
    title: widget.flight == null ? 'Dodaj let' : 'Izmeni let',
    child: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          fields.field('number', 'Broj leta'),
          fields.field('airline', 'Aviokompanija'),
          fields.field(
            'origin',
            'Polazni aerodrom · Grad (KOD)',
            validate: airportError,
          ),
          fields.field(
            'destination',
            'Odredišni aerodrom · Grad (KOD)',
            validate: airportError,
          ),
          SwitchListTile(
            title: const Text('Svakodnevni raspored'),
            subtitle: const Text('Isključite za let određenog datuma.'),
            value: recurring,
            onChanged: (v) => setState(() => recurring = v),
          ),
          fields.field(
            'date',
            'Datum polaska (GGGG-MM-DD)',
            validate: dateError,
          ),
          fields.field(
            'departure',
            'Vreme polaska (HH:mm)',
            validate: timeError,
          ),
          fields.field(
            'arrivalDate',
            'Datum dolaska (GGGG-MM-DD)',
            validate: dateError,
          ),
          fields.field('arrival', 'Vreme dolaska (HH:mm)', validate: timeError),
          fields.field('aircraft', 'Avion'),
          fields.field(
            'capacity',
            'Broj sedišta u avionu',
            validate: (v) =>
                (int.tryParse(v) ?? 0) > 0 && (int.tryParse(v) ?? 0) <= 600
                ? null
                : 'Unesite od 1 do 600 sedišta.',
          ),
          fields.field(
            'price',
            'Osnovna cena (€)',
            validate: (v) => (int.tryParse(v) ?? -1) >= 0
                ? null
                : 'Unesite nenegativan ceo iznos.',
          ),
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Status leta'),
            items: flightStatuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => status = v!,
          ),
          SwitchListTile(
            title: const Text('Direktan let'),
            value: direct,
            onChanged: (v) => setState(() => direct = v),
          ),
          const Text('Vremena su u vremenskoj zoni Europe/Belgrade.'),
          const SizedBox(height: 16),
          FilledButton(onPressed: save, child: const Text('Sačuvaj let')),
        ],
      ),
    ),
  );
  String? airportError(String v) => RegExp(r'^.+ \([A-Z]{3}\)$').hasMatch(v)
      ? null
      : 'Unesite grad i troslovni kod, npr. Beograd (BEG).';
  void save() {
    if (!form.currentState!.validate()) return;
    if (fields.value('origin') == fields.value('destination')) {
      adminMessage(context, 'Aerodromi moraju biti različiti.');
      return;
    }
    final start = DateTime.parse(
      '${fields.value('date')}T${fields.value('departure')}',
    );
    final end = DateTime.parse(
      '${fields.value('arrivalDate')}T${fields.value('arrival')}',
    );
    if (!end.isAfter(start)) {
      adminMessage(context, 'Dolazak mora biti posle polaska.');
      return;
    }
    final old = widget.flight;
    final capacity = int.parse(fields.value('capacity'));
    final duration = end.difference(start);
    try {
      CatalogService.instance.saveFlight(
        Flight(
          fields.value('airline'),
          fields.value('departure'),
          fields.value('arrival'),
          '${duration.inHours} č ${duration.inMinutes % 60} min',
          fields.value('number'),
          int.parse(fields.value('price')),
          direct,
          origin: fields.value('origin'),
          destination: fields.value('destination'),
          date: recurring ? null : parseDate(fields.value('date')),
          arrivalDate: recurring
              ? null
              : parseDate(fields.value('arrivalDate')),
          aircraft: fields.value('aircraft'),
          capacity: capacity,
          status: status,
        ),
        previous: old,
      );
      Navigator.pop(context);
    } on StateError catch (e) {
      adminMessage(context, e.message);
    }
  }
}

class AdminCitiesScreen extends StatelessWidget {
  const AdminCitiesScreen({super.key});
  @override
  Widget build(BuildContext context) => AdminPage(
    title: 'Upravljanje destinacijama',
    action: FloatingActionButton.extended(
      onPressed: () => adminOpen(context, const CityEditor()),
      icon: const Icon(Icons.add),
      label: const Text('Dodaj grad'),
    ),
    child: ListenableBuilder(
      listenable: CatalogService.instance,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          OutlinedButton.icon(
            onPressed: () => adminOpen(context, const AdminReviewsScreen()),
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Pregled recenzija'),
          ),
          if (cities.isEmpty) const Text('Još nema destinacija.'),
          for (final city in cities)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CityImage(city),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${city.name}, ${city.country}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(city.slogan),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () =>
                              adminOpen(context, CityEditor(city: city)),
                          child: const Text('Izmeni'),
                        ),
                        TextButton(
                          onPressed: () =>
                              adminOpen(context, CityDetailsScreen(city: city)),
                          child: const Text('Pregledaj'),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (await confirmAdmin(
                              context,
                              'Obriši destinaciju',
                              'Obrisati ${city.name} i pripadajuće recenzije?',
                            )) {
                              CatalogService.instance.deleteCity(city);
                            }
                          },
                          child: const Text('Obriši'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class CityEditor extends StatefulWidget {
  final City? city;
  const CityEditor({super.key, this.city});
  @override
  State<CityEditor> createState() => _CityEditorState();
}

class _CityEditorState extends State<CityEditor> {
  final form = GlobalKey<FormState>();
  late AdminFields fields;
  @override
  void initState() {
    super.initState();
    final c = widget.city;
    fields = AdminFields({
      'name': c?.name ?? '',
      'country': c?.country ?? '',
      'airport': c?.airport ?? '',
      'file': c?.file ?? '',
      'gallery': c?.gallery.join('\n') ?? '',
      'slogan': c?.slogan ?? '',
      'about': c?.about ?? '',
      'attractions': c?.attractions.join('\n') ?? '',
      'bestTime': c?.bestTime ?? '',
      'currency': c?.currency ?? '',
      'language': c?.language ?? '',
      'timezone': c?.timezone ?? '',
      'budget': c?.budget ?? '',
    });
  }

  @override
  void dispose() {
    fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AdminPage(
    title: widget.city == null ? 'Dodaj grad' : 'Izmeni destinaciju',
    child: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          fields.field('name', 'Naziv grada'),
          fields.field('country', 'Država'),
          fields.field('airport', 'Aerodrom · naziv i kod'),
          fields.field(
            'file',
            'Glavna fotografija · HTTPS URL ili naziv slike iz assets/images',
          ),
          fields.field(
            'gallery',
            'Galerija · jedna putanja ili HTTPS URL po redu',
            required: false,
            lines: 3,
          ),
          fields.field('slogan', 'Kratak opis'),
          fields.field('about', 'Opis grada', lines: 5),
          fields.field('attractions', 'Znamenitosti · jedna po redu', lines: 4),
          fields.field('bestTime', 'Najbolje vreme za posetu', required: false),
          fields.field('currency', 'Valuta', required: false),
          fields.field('language', 'Jezik', required: false),
          fields.field('timezone', 'Vremenska zona', required: false),
          fields.field('budget', 'Okvirni budžet', required: false),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              List<String> lines(String key) => fields
                  .value(key)
                  .split('\n')
                  .map((v) => v.trim())
                  .where((v) => v.isNotEmpty)
                  .toList();
              try {
                CatalogService.instance.saveCity(
                  City(
                    fields.value('name'),
                    fields.value('country'),
                    fields.value('file'),
                    fields.value('slogan'),
                    fields.value('about'),
                    lines('attractions'),
                    airport: fields.value('airport'),
                    gallery: lines('gallery'),
                    bestTime: fields.value('bestTime'),
                    currency: fields.value('currency'),
                    language: fields.value('language'),
                    timezone: fields.value('timezone'),
                    budget: fields.value('budget'),
                    id:
                        widget.city?.key ??
                        'city-${DateTime.now().microsecondsSinceEpoch}',
                  ),
                  previous: widget.city,
                );
                Navigator.pop(context);
              } on StateError catch (e) {
                adminMessage(context, e.message);
              }
            },
            child: const Text('Sačuvaj destinaciju'),
          ),
        ],
      ),
    ),
  );
}

class AdminReviewsScreen extends StatelessWidget {
  const AdminReviewsScreen({super.key});
  @override
  Widget build(BuildContext context) => AdminPage(
    title: 'Pregled recenzija',
    child: ListenableBuilder(
      listenable: CatalogService.instance,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (CatalogService.instance.reviews.isEmpty)
            const Text('Još nema recenzija.'),
          for (final r in CatalogService.instance.reviews)
            Card(
              child: ListTile(
                title: Text('${r.city} · ${r.stars}/5 · ${r.name}'),
                subtitle: Text(r.comment.isEmpty ? 'Bez komentara' : r.comment),
                trailing: IconButton(
                  tooltip: 'Ukloni recenziju',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirmAdmin(
                      context,
                      'Ukloni recenziju',
                      'Trajno ukloniti ovu recenziju?',
                    )) {
                      CatalogService.instance.deleteReview(r);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) => AdminPage(
    title: 'Upravljanje korisnicima',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Pretraži korisnike'),
          onChanged: (v) => setState(() => query = v),
        ),
        for (final u in AuthService.users.where(
          (u) => '${u['name']} ${u['email']}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        ))
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(u['name']!),
              subtitle: Text('${u['email']}\n${u['status']} nalog'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminUserDetails(email: u['email']!),
                  ),
                );
                if (mounted) setState(() {});
              },
            ),
          ),
      ],
    ),
  );
}

class AdminUserDetails extends StatefulWidget {
  final String email;
  const AdminUserDetails({super.key, required this.email});
  @override
  State<AdminUserDetails> createState() => _AdminUserDetailsState();
}

class _AdminUserDetailsState extends State<AdminUserDetails> {
  @override
  Widget build(BuildContext context) {
    final u = AuthService.users.firstWhere((u) => u['email'] == widget.email);
    final blocked = u['status'] == 'Blokiran';
    return AdminPage(
      title: 'Podaci korisnika',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            u['name']!,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Imejl: ${u['email']}'),
          Text('Telefon: ${u['phone']!.isEmpty ? 'Nije unet' : u['phone']}'),
          Text('Datum registracije: ${u['registeredAt']!.split('T').first}'),
          Text('Uloga: ${u['role'] == 'admin' ? 'Administrator' : 'Korisnik'}'),
          Text('Status: ${u['status']}'),
          const SizedBox(height: 16),
          if (widget.email != AuthService.currentUser?['email'])
            OutlinedButton(
              onPressed: () async {
                if (!await confirmAdmin(
                  context,
                  blocked ? 'Odblokiraj nalog' : 'Blokiraj nalog',
                  '${blocked ? 'Odblokirati' : 'Blokirati'} nalog ${u['email']}?',
                )) {
                  return;
                }
                AuthService.setBlocked(widget.email, !blocked);
                if (mounted) setState(() {});
              },
              child: Text(blocked ? 'Odblokiraj nalog' : 'Blokiraj nalog'),
            ),
          const SizedBox(height: 24),
          const Text(
            'Istorija rezervacija',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          for (final entry in NotificationService.instance.bookings.where(
            (e) => e.$1 == widget.email,
          ))
            reservationTile(context, entry),
          if (!NotificationService.instance.bookings.any(
            (e) => e.$1 == widget.email,
          ))
            const Text('Korisnik nema rezervacija.'),
        ],
      ),
    );
  }
}

Widget reservationTile(BuildContext context, (String, Booking) entry) {
  final b = entry.$2;
  return Card(
    child: ListTile(
      title: Text('${b.reference} · ${b.status}'),
      subtitle: Text(
        '${b.passengers.map((p) => '${p['first']} ${p['last']}').join(', ')}\n${entry.$1}\n${b.route}\n${b.dateLabel} · ${b.seats.values.join(', ')} · ${b.total} €',
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => adminOpen(context, AdminReservationDetails(booking: b)),
    ),
  );
}

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});
  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) => AdminPage(
    title: 'Upravljanje rezervacijama',
    child: ListenableBuilder(
      listenable: NotificationService.instance,
      builder: (context, _) {
        final list = NotificationService.instance.bookings
            .where(
              (e) =>
                  '${e.$1} ${e.$2.reference} ${e.$2.route} ${e.$2.passengers}'
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Pretraži rezervacije',
              ),
              onChanged: (v) => setState(() => query = v),
            ),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nema rezervacija.'),
              ),
            for (final entry in list) reservationTile(context, entry),
          ],
        );
      },
    ),
  );
}

class AdminReservationDetails extends StatelessWidget {
  final Booking booking;
  const AdminReservationDetails({super.key, required this.booking});
  @override
  Widget build(BuildContext context) => AdminPage(
    title: 'Detalji rezervacije',
    child: ListenableBuilder(
      listenable: NotificationService.instance,
      builder: (context, _) {
        final b = booking;
        final canCancel = NotificationService.instance.canCancelBooking(b);
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              b.reference!,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text('Status rezervacije: ${b.status}'),
            Text('Plaćanje: ${b.paymentStatus}'),
            Text('${b.flight.number} · ${b.route}'),
            Text('${b.dateLabel} · ${b.flight.departure}–${b.flight.arrival}'),
            Text(
              'Tarifa: ${['Osnovna', 'Standard', 'Fleksibilna'][b.fare]} · ${b.cabin}',
            ),
            Text(
              'Dodatne usluge: ${b.extras.isEmpty ? 'Bez dodataka' : b.extras.map((i) => ['Dodatni prtljag', 'Prioritetno ukrcavanje', 'Putno osiguranje', 'Obrok tokom leta'][i]).join(', ')}',
            ),
            Text('Ukupno: ${b.total} €'),
            const SizedBox(height: 16),
            for (var i = 0; i < b.passengers.length; i++) ...[
              Text(
                '${b.passengers[i]['first']} ${b.passengers[i]['last']} · Sedište ${b.seats[i] ?? 'U krilu odrasle osobe'}',
              ),
              for (final field in [
                ('birth', 'Datum rođenja'),
                ('nationality', 'Državljanstvo'),
                ('passport', 'Broj pasoša'),
                ('email', 'Imejl'),
                ('phone', 'Telefon'),
              ])
                if (b.passengers[i][field.$1]?.isNotEmpty ?? false)
                  Text('${field.$2}: ${b.passengers[i][field.$1]}'),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => adminOpen(context, ReservationScreen(b: b)),
              child: const Text('Pregledaj podatke putovanja'),
            ),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: b.status == 'Otkazana' || b.status == 'Potvrđena'
                      ? null
                      : () => NotificationService.instance.setBookingStatus(
                          b,
                          'Potvrđena',
                        ),
                  child: const Text('Potvrdi rezervaciju'),
                ),
                OutlinedButton(
                  onPressed: !canCancel
                      ? null
                      : () async {
                          if (!await confirmAdmin(
                            context,
                            'Otkaži rezervaciju',
                            'Otkazati ${b.reference}? Sedišta će ponovo biti dostupna.',
                          )) {
                            return;
                          }
                          NotificationService.instance.setBookingStatus(
                            b,
                            'Otkazana',
                          );
                        },
                  child: const Text('Otkaži rezervaciju'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Istorija promena',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            for (final event in b.history.reversed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(event),
              ),
          ],
        );
      },
    ),
  );
}
