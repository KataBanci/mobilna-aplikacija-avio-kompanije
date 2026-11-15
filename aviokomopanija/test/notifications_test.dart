import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aviokomopanija/models/booking.dart';
import 'package:aviokomopanija/services/auth_service.dart';
import 'package:aviokomopanija/services/notification_service.dart';
import 'package:aviokomopanija/screens/notifications_screen.dart';
import 'package:aviokomopanija/screens/booking_screens.dart';

void main() {
  testWidgets('Obaveštenja prate rezervaciju, čitanje i promenu leta', (
    t,
  ) async {
    AuthService.login('katabancsi@gmail.com', 'mennifog04');
    final service = NotificationService.instance;
    final b = Booking()..reference = 'TEST-NOTIFICATION';
    service.confirmBooking(b);
    service.confirmBooking(b);
    expect(service.items.length, 1);
    expect(service.hasUnread, isTrue);
    b.destination = 'Pariz (CDG)';
    expect(service.items.single.booking!.destination, 'Rim (FCO)');
    await t.pumpWidget(const MaterialApp(home: NotificationsScreen()));
    await t.tap(find.text('Rezervacija potvrđena'));
    await t.pumpAndSettle();
    expect(find.byType(ReservationScreen), findsOneWidget);
    expect(service.hasUnread, isFalse);
    AuthService.login('admin', 'admin123');
    expect(service.items, isEmpty);
    expect(
      service.send(
        title: 'Promena vremena leta',
        body: 'Polazak je u 09:10.',
        flightNumber: flights.first.number,
        departure: '09:10',
      ),
      1,
    );
    AuthService.login('katabancsi@gmail.com', 'mennifog04');
    expect(service.items.first.booking!.flight.departure, '09:10');
    expect(service.hasUnread, isTrue);
    service.markAllRead();
    expect(service.hasUnread, isFalse);
    expect(service.send(title: 'Nedozvoljeno', body: 'Test'), 0);
    await t.pumpWidget(const SizedBox());
    b.dispose();
    AuthService.logout();
  });
}
