import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../models/city.dart';
import 'auth_service.dart';
import 'catalog_service.dart';
import 'notification_service.dart';
import 'data_codec.dart';
import 'local_storage.dart';

class LocalDatabase {
  static final error = ValueNotifier<String?>(null);
  static Future<void> _pending = Future.value();
  static bool _started = false;
  static Future<void> initialize() async {
    if (_started) return;
    final raw = await readLocalData();
    if (raw != null) restore(jsonDecode(raw) as Map<String, dynamic>);
    AuthService.onChanged = save;
    CatalogService.instance.addListener(save);
    NotificationService.instance.addListener(save);
    _started = true;
  }

  static Map<String, dynamic> snapshot() => {
    'version': 1,
    'users': AuthService.exportUsers(),
    'flights': flights.map(flightData).toList(),
    'cities': cities.map(cityData).toList(),
    'reviews': [
      for (final r in CatalogService.instance.reviews)
        {
          'city': r.city,
          'owner': r.owner,
          'name': r.name,
          'stars': r.stars,
          'comment': r.comment,
        },
    ],
    'notifications': NotificationService.instance.exportData(),
  };
  static void restore(Map<String, dynamic> data) {
    if (data['version'] != 1) {
      throw const FormatException('Nepoznata verzija lokalne baze.');
    }
    final restoredFlights = (data['flights'] as List)
        .map((d) => flightFromData(Map<String, dynamic>.from(d)))
        .toList();
    final restoredCities = (data['cities'] as List)
        .map((d) => cityFromData(Map<String, dynamic>.from(d)))
        .toList();
    final restoredReviews = (data['reviews'] as List)
        .map(
          (r) => CityReview(
            r['city'],
            r['owner'],
            r['name'],
            r['stars'],
            r['comment'],
          ),
        )
        .toList();
    NotificationService.instance.restoreData(
      Map<String, dynamic>.from(data['notifications']),
    );
    AuthService.restoreUsers(data['users']);
    flights
      ..clear()
      ..addAll(restoredFlights);
    cities
      ..clear()
      ..addAll(restoredCities);
    CatalogService.instance.reviews
      ..clear()
      ..addAll(restoredReviews);
  }

  static void save() {
    final value = jsonEncode(snapshot());
    _pending = _pending.then((_) async {
      try {
        await writeLocalData(value);
        error.value = null;
      } catch (_) {
        error.value = 'Podaci nisu sačuvani na uređaju. Proverite prostor i dozvole za čuvanje.';
      }
    });
  }

  static Future<void> flush() => _pending;
}
