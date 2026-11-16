import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aviokomopanija/models/booking.dart';
import 'package:aviokomopanija/models/city.dart';
import 'package:aviokomopanija/services/auth_service.dart';
import 'package:aviokomopanija/services/catalog_service.dart';
import 'package:aviokomopanija/services/local_database.dart';
import 'package:aviokomopanija/services/notification_service.dart';
import 'package:aviokomopanija/screens/admin/admin_screen.dart';
import 'package:aviokomopanija/screens/admin/management_screens.dart';
import 'package:aviokomopanija/screens/admin/send_notification_screen.dart';
import 'package:aviokomopanija/screens/booking_screens.dart';
import 'package:aviokomopanija/screens/cities_screen.dart';

Map<String, dynamic> snapshot() =>
    jsonDecode(jsonEncode(LocalDatabase.snapshot())) as Map<String, dynamic>;
void admin() => AuthService.login('admin', 'admin123');
void user() => AuthService.login('katabancsi@gmail.com', 'mennifog04');
Booking reserve(String reference, {DateTime? date, String seat = '4D'}) {
  final b = Booking()..reference = reference;
  if (date != null) b.date = date;
  b.seats[0] = seat;
  b.passengers.add({'first': 'Ana', 'last': 'Petrović'});
  NotificationService.instance.confirmBooking(b);
  return NotificationService.instance.myBookings.firstWhere(
    (b) => b.reference == reference,
  );
}

void main() {
  late Map<String, dynamic> original;
  setUp(() {
    original = snapshot();
    AuthService.logout();
  });
  tearDown(() {
    LocalDatabase.restore(original);
    AuthService.logout();
  });

  test('Blokiranje sprečava prijavu; javni podaci ne sadrže lozinke', () {
    admin();
    expect(AuthService.users.every((u) => !u.containsKey('password')), isTrue);
    AuthService.setBlocked('katabancsi@gmail.com', true);
    expect(AuthService.login('katabancsi@gmail.com', 'mennifog04'), isFalse);
    expect(AuthService.currentUser, isNull);
    admin();
    AuthService.setBlocked('admin', true);
    expect(
      AuthService.users.firstWhere((u) => u['email'] == 'admin')['status'],
      'Aktivan',
    );
    AuthService.setBlocked('katabancsi@gmail.com', false);
    expect(AuthService.login('katabancsi@gmail.com', 'mennifog04'), isTrue);
  });

  test('Slanje određenom korisniku, letu i svim korisnicima', () {
    final service = NotificationService.instance;
    AuthService.register('Maja Petrović', 'maja@example.com', 'test12345');
    user();
    reserve('TARGETED');
    admin();
    expect(
      service.send(
        title: 'Lično',
        body: 'Za Maju',
        recipientEmail: 'maja@example.com',
      ),
      1,
    );
    expect(
      service.send(
        title: 'Let',
        body: 'Za putnike',
        flightNumber: flights.first.number,
      ),
      1,
    );
    expect(service.send(title: 'Svi', body: 'Ponuda'), 2);
    user();
    expect(service.items.any((n) => n.title == 'Lično'), isFalse);
    expect(
      service.items.any(
        (n) => n.title == 'Let' && n.booking?.reference == 'TARGETED',
      ),
      isTrue,
    );
    AuthService.login('maja@example.com', 'test12345');
    expect(service.items.map((n) => n.title), containsAll(['Lično', 'Svi']));
    expect(service.items.any((n) => n.title == 'Let'), isFalse);
  });

  test('Promena leta obaveštava putnike i čuva kupljenu cenu; otkazivanje oslobađa sedišta', () {
    final service = NotificationService.instance;
    user();
    final b = reserve('FLIGHT-CHANGE');
    final total = b.total;
    final old = flights.first;
    final candidate = Booking()
      ..date = b.date
      ..seats[0] = '4D';
    expect(service.occupiedSeats(candidate), contains('4D'));
    expect(service.validateBooking(candidate), contains('zauzeto'));
    admin();
    final changed = Flight(
      old.airline,
      '09:10',
      '11:05',
      old.duration,
      old.number,
      120,
      true,
      status: 'Odložen',
    );
    CatalogService.instance.saveFlight(changed, previous: old);
    expect(b.flight.departure, '09:10');
    expect(b.total, total);
    user();
    expect(service.items.first.title, 'Promena podataka leta');
    expect(service.items.first.booking, same(b));
    admin();
    CatalogService.instance.saveFlight(
      copyFlight(changed, status: 'Otkazan'),
      previous: changed,
    );
    expect(b.status, 'Otkazana');
    expect(service.occupiedSeats(candidate), isEmpty);
    user();
    expect(service.items.first.title, 'Let je otkazan');
    expect(b.history.length, 3);
  });

  test('Otkazivanje rezervacije oslobađa sedište samo na njenom datumu', () {
    final service = NotificationService.instance;
    user();
    final first = reserve('CANCEL-FIRST');
    final next = reserve(
      'CANCEL-NEXT',
      date: first.date.add(const Duration(days: 1)),
    );
    final draft = Booking()..date = first.date;
    expect(
      service.availableSeats(first.flight, first.date),
      first.flight.capacity - 1,
    );
    admin();
    service.setBookingStatus(first, 'Otkazana');
    expect(service.occupiedSeats(draft), isEmpty);
    expect(
      service.availableSeats(first.flight, first.date),
      first.flight.capacity,
    );
    draft.date = next.date;
    expect(service.occupiedSeats(draft), contains('4D'));
    expect(
      () => service.setBookingStatus(first, 'Potvrđena'),
      throwsStateError,
    );
  });

  test('Izmena leta odbija preklapanje rezervisanih sedišta', () {
    user();
    final first = reserve('CLASH-FIRST');
    reserve('CLASH-NEXT', date: first.date.add(const Duration(days: 1)));
    admin();
    final old = flights.first;
    expect(
      () => CatalogService.instance.saveFlight(
        Flight(
          old.airline,
          old.departure,
          old.arrival,
          old.duration,
          old.number,
          old.price,
          true,
          date: first.date,
        ),
        previous: old,
      ),
      throwsStateError,
    );
    expect(flights.first, same(old));
  });

  test('Lokalna baza vraća rezervacije, istoriju, pročitane poruke i blokirane naloge', () {
    user();
    final b = reserve('PERSISTED');
    NotificationService.instance.markAllRead();
    admin();
    AuthService.setBlocked('katabancsi@gmail.com', true);
    final saved = snapshot();
    final encoded = jsonEncode(saved);
    expect(encoded, isNot(contains('cardNumber')));
    NotificationService.instance.restoreData({
      'bookings': [],
      'notifications': [],
    });
    AuthService.setBlocked('katabancsi@gmail.com', false);
    LocalDatabase.restore(jsonDecode(encoded) as Map<String, dynamic>);
    final restored = NotificationService.instance.bookings.single.$2;
    expect(restored.reference, b.reference);
    expect(restored.seats[0], '4D');
    expect(restored.history, b.history);
    expect(AuthService.login('katabancsi@gmail.com', 'mennifog04'), isFalse);
    admin();
    AuthService.setBlocked('katabancsi@gmail.com', false);
    user();
    expect(NotificationService.instance.hasUnread, isFalse);
    expect(NotificationService.instance.items.first.booking, same(restored));
  });

  testWidgets('Svako dugme administracije otvara pravi ekran', (t) async {
    admin();
    await t.pumpWidget(const MaterialApp(home: AdminScreen()));
    for (final entry in <String, Type>{
      'Pošalji obaveštenje': SendNotificationScreen,
      'Letovi': AdminFlightsScreen,
      'Destinacije': AdminCitiesScreen,
      'Korisnici': AdminUsersScreen,
      'Rezervacije': AdminReservationsScreen,
    }.entries) {
      await t.ensureVisible(find.text(entry.key));
      await t.tap(find.text(entry.key));
      await t.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget);
      await t.pageBack();
      await t.pumpAndSettle();
    }
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'Grad, informacije, galerija i moderacija recenzija stižu korisniku',
    (t) async {
      admin();
      final city = City(
        'Test grad',
        'Srbija',
        'rome.jpg',
        'Novi grad',
        'Opis grada',
        ['Trg'],
        id: 'test-city',
        airport: 'Test (TES)',
        gallery: ['Paris.jpg'],
        bestTime: 'Proleće',
        currency: 'RSD',
        language: 'Srpski',
        timezone: 'Europe/Belgrade',
        budget: '100 €',
      );
      CatalogService.instance.saveCity(city);
      user();
      CatalogService.instance.saveReview(city, 4, 'Lep grad');
      await t.pumpWidget(MaterialApp(home: CityDetailsScreen(city: city)));
      await t.scrollUntilVisible(
        find.text('Valuta: RSD'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Aerodrom: Test (TES)'), findsOneWidget);
      await t.scrollUntilVisible(
        find.text('Kata Banči · 4/5\nLep grad'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      admin();
      CatalogService.instance.deleteReview(
        CatalogService.instance.reviews.single,
      );
      await t.pumpAndSettle();
      expect(find.text('Kata Banči · 4/5\nLep grad'), findsNothing);
      final edited = City(
        'Novo ime',
        'Srbija',
        'Paris.jpg',
        'Izmenjen grad',
        'Opis',
        ['Muzej'],
        id: city.key,
      );
      CatalogService.instance.saveCity(edited, previous: city);
      await t.pumpAndSettle();
      expect(find.text('Novo ime'), findsOneWidget);
      CatalogService.instance.deleteCity(edited);
      await t.pumpAndSettle();
      expect(find.text('Ova destinacija više nije dostupna.'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Novi let se dodaje kroz formular i pojavljuje u korisničkoj pretrazi',
    (t) async {
      t.view.physicalSize = const Size(900, 2200);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      admin();
      await t.pumpWidget(const MaterialApp(home: AdminFlightsScreen()));
      await t.tap(find.text('Dodaj let'));
      await t.pumpAndSettle();
      Future<void> enter(String label, String value) async {
        final field = find.widgetWithText(TextFormField, label);
        await t.ensureVisible(field);
        await t.enterText(field, value);
      }

      await enter('Broj leta', 'AV999');
      await enter('Aviokompanija', 'Test Air');
      await enter('Polazni aerodrom · Grad (KOD)', 'Beograd (BEG)');
      await enter('Odredišni aerodrom · Grad (KOD)', 'Rim (FCO)');
      await enter('Vreme polaska (HH:mm)', '08:20');
      await enter('Vreme dolaska (HH:mm)', '10:15');
      await enter('Avion', 'Airbus A320');
      await t.ensureVisible(find.text('Sačuvaj let'));
      await t.tap(find.text('Sačuvaj let'));
      await t.pumpAndSettle();
      expect(flights.any((f) => f.number == 'AV999'), isTrue);
      user();
      await t.pumpWidget(MaterialApp(home: ResultsScreen(b: Booking())));
      await t.pumpAndSettle();
      expect(find.text('Test Air'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
}
