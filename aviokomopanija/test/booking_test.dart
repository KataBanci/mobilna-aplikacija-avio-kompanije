import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aviokomopanija/main.dart';
import 'package:aviokomopanija/models/booking.dart';
import 'package:aviokomopanija/screens/booking_screens.dart';

void main() {
  test('Ukupna cena prati putnike, tarifu, sedišta i dodatke', () {
    final b = Booking();
    expect(b.total, 89);
    b.adults = 2;
    b.fare = 1;
    b.extras.addAll([0, 2]);
    b.seats.addAll({0: '1A', 1: '4D'});
    expect(b.total, 329);
    b.roundTrip = true;
    expect(b.total, 567);
    b.extras.remove(0);
    expect(b.total, 509);
    b.dispose();
  });
  testWidgets('Pretraga, izbor leta i provera obaveznih podataka', (t) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(const MyApp());
    await t.ensureVisible(find.text('Nastavi kao gost'));
    await t.tap(find.text('Nastavi kao gost'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Pretraži letove'));
    await t.tap(find.text('Pretraži letove'));
    await t.pumpAndSettle();
    expect(find.text('Beograd → Rim'), findsOneWidget);
    await t.ensureVisible(find.text('Air Serbia'));
    await t.tap(find.text('Air Serbia'));
    await t.pumpAndSettle();
    expect(find.byType(DetailsScreen), findsOneWidget);
    await t.tap(find.text('Nastavi'));
    await t.pumpAndSettle();
    await t.tap(find.text('Nastavi na izbor sedišta'));
    await t.pumpAndSettle();
    expect(find.text('Unesite ime.'), findsOneWidget);
    expect(find.byType(PassengerScreen), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('Sedište se ne deli između putnika, dodaci menjaju cenu', (
    t,
  ) async {
    final b = Booking()..adults = 2;
    b.passengers.addAll([
      {'first': 'Marko', 'last': 'Petrović'},
      {'first': 'Ana', 'last': 'Petrović'},
    ]);
    await t.pumpWidget(MaterialApp(home: SeatsScreen(b: b)));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('4D'), 100);
    await t.tap(find.text('4D'));
    await t.pumpAndSettle();
    expect(b.seats[0], '4D');
    await t.tap(find.text('Nastavi'));
    await t.pumpAndSettle();
    expect(find.text('Izaberite sedište za svakog putnika.'), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
    b.seats[1] = '4E';
    await t.tap(find.text('Nastavi'));
    await t.pumpAndSettle();
    expect(find.byType(ExtrasScreen), findsOneWidget);
    await t.tap(find.byTooltip('Dodaj').first);
    await t.pumpAndSettle();
    expect(b.total, 236);
    await t.tap(find.byTooltip('Ukloni'));
    await t.pumpAndSettle();
    expect(b.total, 178);
    expect(t.takeException(), isNull);
  });
}
