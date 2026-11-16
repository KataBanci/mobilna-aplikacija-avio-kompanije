import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import 'auth_service.dart';
import 'data_codec.dart';

class AppNotification {
  final String owner, title, body;
  final DateTime createdAt;
  final Booking? booking;
  bool isRead = false;
  AppNotification(
    this.owner,
    this.title,
    this.body, {
    this.booking,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class NotificationService extends ChangeNotifier {
  static final instance = NotificationService();
  final List<AppNotification> _items = [];
  final Map<String, (String, Booking)> _bookings = {};
  List<(String, Booking)> get bookings => List.unmodifiable(_bookings.values);
  List<Booking> get myBookings =>
      bookings.where((e) => e.$1 == owner).map((e) => e.$2).toList();
  List<AppNotification> get sent =>
      AuthService.isAdmin ? List.unmodifiable(_items.reversed) : [];
  void changed() => notifyListeners();
  Map<String, dynamic> exportData() => {
    'bookings': [
      for (final e in bookings) {'owner': e.$1, 'booking': bookingData(e.$2)},
    ],
    'notifications': [
      for (final n in _items)
        {
          'owner': n.owner,
          'title': n.title,
          'body': n.body,
          'createdAt': n.createdAt.toIso8601String(),
          'reference': n.booking?.reference,
          'isRead': n.isRead,
        },
    ],
  };
  void restoreData(Map<String, dynamic> data) {
    final restored = <String, (String, Booking)>{};
    for (final e in data['bookings'] as List) {
      final b = bookingFromData(Map<String, dynamic>.from(e['booking']));
      restored[b.reference!] = (e['owner'] as String, b);
    }
    final notifications = <AppNotification>[];
    for (final n in data['notifications'] as List) {
      notifications.add(
        AppNotification(
          n['owner'],
          n['title'],
          n['body'],
          booking: restored[n['reference']]?.$2,
          createdAt: DateTime.parse(n['createdAt']),
        )..isRead = n['isRead'],
      );
    }
    _bookings
      ..clear()
      ..addAll(restored);
    _items
      ..clear()
      ..addAll(notifications);
  }

  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  Set<String> occupiedSeats(Booking b) => bookings
      .where(
        (e) =>
            e.$2.reference != b.reference &&
            e.$2.status != 'Otkazana' &&
            e.$2.flight.number == b.flight.number &&
            sameDay(e.$2.date, b.date),
      )
      .expand((e) => e.$2.seats.values)
      .toSet();
  int availableSeats(Flight f, DateTime date) =>
      f.capacity -
      bookings
          .where(
            (e) =>
                e.$2.status != 'Otkazana' &&
                e.$2.flight.number == f.number &&
                sameDay(e.$2.date, date),
          )
          .fold<int>(0, (total, e) => total + e.$2.seatCount);
  String? validateBooking(Booking b) {
    final current = flights
        .where((f) => f.number == b.flight.number)
        .firstOrNull;
    if (current == null ||
        current.status == 'Otkazan' ||
        current.status == 'Završen') {
      return 'Let više nije dostupan.';
    }
    if (current.origin != b.origin ||
        current.destination != b.destination ||
        (current.date != null && !sameDay(current.date!, b.date))) {
      return 'Podaci leta su promenjeni. Ponovite pretragu.';
    }
    if (availableSeats(current, b.date) < b.seatCount) {
      return 'Nema dovoljno slobodnih sedišta.';
    }
    if (b.seats.values.any(occupiedSeats(b).contains)) {
      return 'Izabrano sedište je u međuvremenu zauzeto. Izaberite drugo.';
    }
    return null;
  }

  bool canCancelBooking(Booking b) {
    final time = b.flight.departure.split(':');
    final departure = DateTime(
      b.date.year,
      b.date.month,
      b.date.day,
      int.parse(time[0]),
      int.parse(time[1]),
    );
    return b.status != 'Otkazana' &&
        b.flight.status != 'Završen' &&
        departure.isAfter(DateTime.now());
  }

  void setBookingStatus(Booking b, String status) {
    if (!AuthService.isAdmin || b.status == status) return;
    if (b.status == 'Otkazana') {
      throw StateError('Otkazana rezervacija ne može ponovo da se potvrdi.');
    }
    if (!['Potvrđena', 'Otkazana'].contains(status)) {
      throw StateError('Nepoznat status rezervacije.');
    }
    if (status == 'Otkazana' && !canCancelBooking(b)) {
      throw StateError('Rezervacija završenog putovanja ne može da se otkaže.');
    }
    b.status = status;
    b.history.add('${DateTime.now().toIso8601String()} · Rezervacija: $status');
    final email = bookings.firstWhere((e) => identical(e.$2, b)).$1;
    _items.add(
      AppNotification(
        email,
        'Rezervacija: $status',
        '${b.reference} · ${b.route}',
        booking: b,
      ),
    );
    b.update();
    notifyListeners();
  }

  void updateFlight(Flight previous, Flight next) {
    if (!AuthService.isAdmin) return;
    for (final entry in bookings) {
      final b = entry.$2;
      if (b.flight.number != previous.number || b.status == 'Otkazana') {
        continue;
      }
      final changed =
          previous.departure != next.departure ||
          previous.arrival != next.arrival ||
          previous.date != next.date ||
          previous.status != next.status ||
          previous.origin != next.origin ||
          previous.destination != next.destination;
      b.flight = Flight(
        next.airline,
        next.departure,
        next.arrival,
        next.duration,
        next.number,
        b.flight.price,
        next.direct,
        origin: next.origin,
        destination: next.destination,
        aircraft: next.aircraft,
        status: next.status,
        date: next.date,
        arrivalDate: next.arrivalDate,
        capacity: next.capacity,
      );
      b.origin = next.origin;
      b.destination = next.destination;
      if (next.date != null) b.date = next.date!;
      b.flightStatus = next.status == 'Otkazan'
          ? 'Let je otkazan.'
          : '${next.status} · ${next.departure}–${next.arrival}';
      if (next.status == 'Otkazan') b.status = 'Otkazana';
      if (changed) {
        b.history.add(
          '${DateTime.now().toIso8601String()} · ${b.flightStatus}',
        );
        _items.add(
          AppNotification(
            entry.$1,
            next.status == 'Otkazan'
                ? 'Let je otkazan'
                : 'Promena podataka leta',
            '${b.route} · ${b.dateLabel} · ${b.flightStatus}',
            booking: b,
          ),
        );
      }
      b.update();
    }
    notifyListeners();
  }

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
    b.bookedTotal = source.total;
    b.history.add(
      '${DateTime.now().toIso8601String()} · Rezervacija potvrđena; demonstraciono plaćanje.',
    );
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
          b.status == 'Otkazana' ||
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
    String? recipientEmail,
  }) {
    if (AuthService.currentUser?['role'] != 'admin') return 0;
    var sent = 0;
    if (flightNumber == null) {
      for (final email
          in recipientEmail == null
              ? AuthService.userEmails
              : AuthService.userEmails.where((e) => e == recipientEmail)) {
        _items.add(AppNotification(email, title, body));
        sent++;
      }
    } else {
      for (final entry in _bookings.values) {
        final b = entry.$2;
        if (b.flight.number != flightNumber || b.status == 'Otkazana') continue;
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
