import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aviokomopanija/models/booking.dart';
import 'package:aviokomopanija/main.dart';
import 'package:aviokomopanija/screens/booking_screens.dart';
import 'package:aviokomopanija/services/calendar_service.dart';

void main() {
  test('Telefon prihvata lokalni, kratak i međunarodni broj', () {
    for (final phone in [
      '1',
      '0641234567',
      '+38106425637832',
      '+381 64 123 4567',
      '011/123456',
    ]) {
      expect(validatePhone(phone), isNull, reason: phone);
    }
    expect(validatePhone('telefon'), isNotNull);
  });
  testWidgets('Iz pregleda rezervacije može na početnu i na putovanja', (
    t,
  ) async {
    await t.pumpWidget(const MyApp());
    await t.ensureVisible(find.text('Nastavi kao gost'));
    await t.tap(find.text('Nastavi kao gost'));
    await t.pumpAndSettle();
    final search = t.widget<SearchScreen>(find.byType(SearchScreen));
    final b = search.b..reference = 'AV123456';
    b.passengers.add({'first': 'Ana', 'last': 'Petrović'});
    b.seats[0] = '4D';
    open(t.element(find.byType(SearchScreen)), ReservationScreen(b: b));
    await t.pumpAndSettle();
    await t.tap(find.text('Nazad na početnu'));
    await t.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.byType(ReservationScreen), findsNothing);
    expect(b.reference, 'AV123456');
    open(t.element(find.byType(SearchScreen)), ReservationScreen(b: b));
    await t.pumpAndSettle();
    await t.tap(find.text('Putovanja'));
    await t.pumpAndSettle();
    expect(find.byType(TripsScreen), findsOneWidget);
    expect(find.text('AV123456'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  test('Kalendar sadrži let, vremensku zonu i podsetnik', () {
    final b = Booking()..reference = 'AV123456';
    final text = calendarContents(b);
    expect(text, contains('BEGIN:VCALENDAR\r\n'));
    expect(text, contains('DTSTART;TZID=Europe/Belgrade:'));
    expect(text, contains('UID:AV123456@airvista.example'));
    expect(text, contains('TRIGGER:-PT2H'));
    expect(text, contains('END:VCALENDAR\r\n'));
  });
  testWidgets(
    'Neispravna kartica se odbija, probno plaćanje potvrđuje rezervaciju',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final b = Booking();
      b.passengers.add({'first': 'Marko', 'last': 'Petrović'});
      b.seats[0] = '4D';
      await t.pumpWidget(MaterialApp(home: PaymentScreen(b: b)));
      await t.tap(find.text('Plati · 89 €'));
      await t.pumpAndSettle();
      expect(
        find.text('Unesite ispravan probni broj kartice.'),
        findsOneWidget,
      );
      expect(b.reference, isNull);
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), '4242 4242 4242 4242');
      await t.enterText(fields.at(1), '12/39');
      await t.enterText(fields.at(2), '123');
      await t.enterText(fields.at(3), 'Marko Petrović');
      await t.ensureVisible(find.byType(CheckboxListTile));
      await t.tap(find.byType(CheckboxListTile));
      await t.pumpAndSettle();
      await t.tap(find.text('Plati · 89 €'));
      await t.pumpAndSettle();
      expect(find.byType(ConfirmationScreen), findsOneWidget);
      expect(b.reference, startsWith('AV'));
      await t.ensureVisible(find.text('Pregledaj rezervaciju'));
      await t.tap(find.text('Pregledaj rezervaciju'));
      await t.pumpAndSettle();
      expect(find.byType(ReservationScreen), findsOneWidget);
      expect(find.text('Marko Petrović'), findsOneWidget);
      expect(find.text('4D'), findsOneWidget);
      expect(find.text('Nazad na početnu'), findsOneWidget);
      expect(find.byTooltip('Početna'), findsOneWidget);
      await t.tap(find.byTooltip('Nazad'));
      await t.pumpAndSettle();
      expect(find.byType(ConfirmationScreen), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
}
