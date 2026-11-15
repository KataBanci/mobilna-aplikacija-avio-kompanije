import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import 'auth_service.dart';

class AppNotification {
  final String owner, title, body;
  final DateTime createdAt;
  final Booking? booking;
  bool isRead = false;
  AppNotification(this.owner, this.title, this.body, {this.booking})
    : createdAt = DateTime.now();
}

class NotificationService extends ChangeNotifier {
  static final instance = NotificationService();
  final List<AppNotification> _items = [];
  final Map<String, (String, Booking)> _bookings = {};
  String get owner => AuthService.currentUser?['email'] ?? 'guest';
  List<AppNotification> get items => List.unmodifiable(
    _items.where((n) => n.owner == owner).toList().reversed,
  );
  bool get hasUnread => items.any((n) => !n.isRead);

  void markRead(AppNotification item) {
    if (item.owner != owner) return;
    item.isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final item in items) {
      item.isRead = true;
    }
    notifyListeners();
  }

  void confirmBooking(Booking source) {
    final reference = source.reference;
    if (reference == null || _bookings.containsKey(reference)) return;
    // A separate copy keeps old notifications linked to the original trip.
    final b = Booking()
      ..origin = source.origin
      ..destination = source.destination
      ..date = source.date
      ..returnDate = source.returnDate
      ..roundTrip = source.roundTrip
      ..adults = source.adults
      ..children = source.children
      ..infants = source.infants
      ..cabin = source.cabin
      ..flight = source.flight
      ..fare = source.fare
      ..reference = reference;
    b.extras.addAll(source.extras);
    b.seats.addAll(source.seats);
    b.passengers.addAll(
      source.passengers.map((p) => Map<String, String>.of(p)),
    );
    _bookings[reference] = (owner, b);
    _items.add(
      AppNotification(
        owner,
        'Rezervacija potvrđena',
        'Uspešno ste rezervisali let ${b.route} za ${b.dateLabel}',
        booking: b,
      ),
    );
    refreshReminders();
    notifyListeners();
  }

  void refreshReminders() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    var changed = false;
    for (final entry in _bookings.values) {
      final b = entry.$2;
      if (entry.$1 != owner ||
          b.flightStatus == 'Let je otkazan.' ||
          b.date.year != tomorrow.year ||
          b.date.month != tomorrow.month ||
          b.date.day != tomorrow.day ||
          _items.any(
            (n) => n.booking == b && n.title == 'Podsetnik za putovanje',
          )) {
        continue;
      }
      _items.add(
        AppNotification(
          owner,
          'Podsetnik za putovanje',
          'Vaš let ${b.route} je sutra. Proverite podatke o putovanju.',
          booking: b,
        ),
      );
      changed = true;
    }
    if (changed) notifyListeners();
  }

  int send({
    required String title,
    required String body,
    String? flightNumber,
    String? departure,
    bool cancelled = false,
  }) {
    if (AuthService.currentUser?['role'] != 'admin') return 0;
    var sent = 0;
    if (flightNumber == null) {
      for (final email in AuthService.userEmails) {
        _items.add(AppNotification(email, title, body));
        sent++;
      }
    } else {
      for (final entry in _bookings.values) {
        final b = entry.$2;
        if (b.flight.number != flightNumber) continue;
        if (cancelled) b.flightStatus = 'Let je otkazan.';
        if (departure != null) {
          final f = b.flight;
          b.flightStatus = 'Novo vreme polaska: $departure';
          b.flight = Flight(
            f.airline,
            departure,
            f.arrival,
            f.duration,
            f.number,
            f.price,
            f.direct,
          );
        }
        _items.add(AppNotification(entry.$1, title, body, booking: b));
        sent++;
      }
    }
    notifyListeners();
    return sent;
  }
}
