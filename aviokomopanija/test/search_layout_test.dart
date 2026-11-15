import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aviokomopanija/models/booking.dart';
import 'package:aviokomopanija/screens/booking_screens.dart';

void main() {
  for (final width in [320.0, 393.0, 560.0]) {
    testWidgets('Sažeta pretraga bez preklapanja na širini $width', (t) async {
      t.view.physicalSize = Size(width, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final b = Booking();
      await t.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: Scaffold(body: SearchScreen(b: b)),
        ),
      );
      await t.pumpAndSettle();
      final origin = t.getRect(find.byKey(const ValueKey('origin-picker')));
      final destination = t.getRect(
        find.byKey(const ValueKey('destination-picker')),
      );
      expect(origin.overlaps(destination), isFalse);
      expect(origin.top, destination.top);
      await t.tap(find.byTooltip('Zameni polazište i odredište'));
      await t.pumpAndSettle();
      expect(b.origin, 'Rim (FCO)');
      expect(b.destination, 'Beograd (BEG)');
      await t.ensureVisible(find.text('Putnici i klasa'));
      await t.tap(find.text('Putnici i klasa'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Povećaj: Odrasli'));
      await t.tap(find.byTooltip('Povećaj: Deca'));
      await t.tap(find.text('Potvrdi'));
      await t.pumpAndSettle();
      expect(b.adults, 2);
      expect(b.children, 1);
      expect(find.text('3 putnika'), findsOneWidget);
      await t.ensureVisible(find.text('Povratno'));
      await t.tap(find.text('Povratno'));
      await t.pumpAndSettle();
      expect(b.roundTrip, isTrue);
      expect(find.text('Povratak'), findsOneWidget);
      await t.ensureVisible(find.text('Pretraži letove'));
    });
  }
  testWidgets('Otkazivanje izmene putnika zadržava prethodni izbor', (t) async {
    final b = Booking();
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SearchScreen(b: b)),
      ),
    );
    await t.ensureVisible(find.text('Putnici i klasa'));
    await t.tap(find.text('Putnici i klasa'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Povećaj: Odrasli'));
    await t.tap(find.text('Otkaži'));
    await t.pumpAndSettle();
    expect(b.count, 1);
    expect(t.takeException(), isNull);
  });
}
