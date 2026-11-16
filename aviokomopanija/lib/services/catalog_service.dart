import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/city.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class CityReview {
  final String city, owner, name, comment;
  final int stars;
  CityReview(this.city, this.owner, this.name, this.stars, this.comment);
}

class CatalogService extends ChangeNotifier {
  static final instance = CatalogService();
  final List<CityReview> reviews = [];
  void changed() => notifyListeners();
  void saveFlight(Flight flight, {Flight? previous}) {
    if (!AuthService.isAdmin) return;
    if (flights.any((f) => f != previous && f.number == flight.number)) {
      throw StateError('Broj leta već postoji.');
    }
    if (previous != null && flight.status != 'Otkazan') {
      final active = NotificationService.instance.bookings.where(
        (e) =>
            e.$2.flight.number == previous.number && e.$2.status != 'Otkazana',
      );
      final seatsByDate = <String, Set<String>>{};
      final counts = <String, int>{};
      for (final entry in active) {
        final b = entry.$2;
        final date = flight.date ?? b.date;
        final key = '${date.year}-${date.month}-${date.day}';
        final seats = seatsByDate.putIfAbsent(key, () => <String>{});
        counts[key] = (counts[key] ?? 0) + b.seatCount;
        if (counts[key]! > flight.capacity) {
          throw StateError('Kapacitet je manji od broja rezervisanih sedišta.');
        }
        for (final seat in b.seats.values) {
          final index =
              (int.parse(seat.substring(0, seat.length - 1)) - 1) * 6 +
              seat.codeUnitAt(seat.length - 1) -
              64;
          if (index > flight.capacity || !seats.add(seat)) {
            throw StateError(
              'Izmena bi napravila preklapanje ili uklonila rezervisano sedište.',
            );
          }
        }
      }
    }
    if (previous == null) {
      flights.add(flight);
    } else {
      flights[flights.indexOf(previous)] = flight;
      NotificationService.instance.updateFlight(previous, flight);
    }
    notifyListeners();
  }

  void saveCity(City city, {City? previous}) {
    if (!AuthService.isAdmin) return;
    if (cities.any(
      (c) => c != previous && c.name.toLowerCase() == city.name.toLowerCase(),
    )) {
      throw StateError('Grad sa ovim nazivom već postoji.');
    }
    if (previous == null) {
      cities.insert(0, city);
    } else {
      cities[cities.indexOf(previous)] = city;
      for (var i = 0; i < reviews.length; i++) {
        final r = reviews[i];
        if (r.city == previous.name) {
          reviews[i] = CityReview(
            city.name,
            r.owner,
            r.name,
            r.stars,
            r.comment,
          );
        }
      }
    }
    notifyListeners();
  }

  void deleteCity(City city) {
    if (!AuthService.isAdmin) return;
    cities.remove(city);
    reviews.removeWhere((r) => r.city == city.name);
    notifyListeners();
  }

  void saveReview(City city, int stars, String comment) {
    final owner = AuthService.currentUser?['email'] ?? 'guest';
    reviews.removeWhere((r) => r.city == city.name && r.owner == owner);
    reviews.add(
      CityReview(
        city.name,
        owner,
        AuthService.currentUser?['name'] ?? 'Gost',
        stars,
        comment,
      ),
    );
    notifyListeners();
  }

  void deleteReview(CityReview review) {
    if (!AuthService.isAdmin) return;
    reviews.remove(review);
    notifyListeners();
  }
}
