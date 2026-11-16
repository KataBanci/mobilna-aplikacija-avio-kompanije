import 'package:flutter/material.dart';

class Flight {
  final String airline, departure, arrival, duration, number;
  final int price;
  final bool direct;
  final String origin, destination, aircraft, status;
  final DateTime? date, arrivalDate;
  final int capacity;
  const Flight(
    this.airline,
    this.departure,
    this.arrival,
    this.duration,
    this.number,
    this.price,
    this.direct, {
    this.origin = 'Beograd (BEG)',
    this.destination = 'Rim (FCO)',
    this.aircraft = 'Airbus A320',
    this.status = 'Zakazan',
    this.date,
    this.arrivalDate,
    this.capacity = 180,
  });
}

final flights = [
  Flight('Air Serbia', '08:20', '10:15', '1 č 55 min', 'JU 530', 89, true),
  Flight('Ryanair', '14:35', '16:30', '1 č 55 min', 'FR 7941', 95, true),
  Flight('Wizz Air', '18:10', '20:05', '1 č 55 min', 'W6 4115', 109, true),
  Flight('Lufthansa', '12:45', '17:20', '4 č 35 min', 'LH 1407', 179, false),
];

class Booking extends ChangeNotifier {
  int tab = 0;
  String origin = 'Beograd (BEG)', destination = 'Rim (FCO)';
  DateTime date = DateTime.now().add(const Duration(days: 14));
  DateTime? returnDate;
  bool roundTrip = false;
  int adults = 1, children = 0, infants = 0;
  String cabin = 'Ekonomska';
  Flight flight = flights.first;
  int fare = 0;
  final Set<int> extras = {};
  final Set<String> favorites = {};
  final Map<int, String> seats = {};
  final List<Map<String, String>> passengers = [];
  String? reference;
  String? flightStatus;
  String status = 'Potvrđena';
  String paymentStatus = 'Demonstraciono plaćanje potvrđeno';
  int? bookedTotal;
  final List<String> history = [];
  int get count => adults + children + infants;
  int get seatCount => adults + children;
  int get farePrice => flight.price + [0, 30, 60][fare];
  int get seatCost =>
      seats.values.where((s) => RegExp(r'^1[A-F]$').hasMatch(s)).length * 15;
  int get extrasCost =>
      extras.fold<int>(0, (sum, i) => sum + [29, 12, 9, 11][i] * count);
  int get baseCost =>
      (farePrice + (cabin == 'Biznis' ? 100 : 0)) * count * (roundTrip ? 2 : 1);
  int get total => bookedTotal ?? baseCost + extrasCost + seatCost;
  String get route =>
      '${origin.split(' (').first} → ${destination.split(' (').first}';
  String code(String airport) => airport.split('(').last.replaceAll(')', '');
  String get dateLabel => '${date.day}.${date.month}.${date.year}.';
  void update() => notifyListeners();
}
