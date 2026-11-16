import '../models/booking.dart';
import '../models/city.dart';

Map<String, dynamic> flightData(Flight f) => {
  'airline': f.airline,
  'departure': f.departure,
  'arrival': f.arrival,
  'duration': f.duration,
  'number': f.number,
  'price': f.price,
  'direct': f.direct,
  'origin': f.origin,
  'destination': f.destination,
  'aircraft': f.aircraft,
  'status': f.status,
  'date': f.date?.toIso8601String(),
  'arrivalDate': f.arrivalDate?.toIso8601String(),
  'capacity': f.capacity,
};
Flight flightFromData(Map<String, dynamic> d) => Flight(
  d['airline'],
  d['departure'],
  d['arrival'],
  d['duration'],
  d['number'],
  d['price'],
  d['direct'],
  origin: d['origin'],
  destination: d['destination'],
  aircraft: d['aircraft'],
  status: d['status'],
  date: DateTime.tryParse(d['date'] ?? ''),
  arrivalDate: DateTime.tryParse(d['arrivalDate'] ?? ''),
  capacity: d['capacity'],
);
Map<String, dynamic> cityData(City c) => {
  'id': c.key,
  'name': c.name,
  'country': c.country,
  'file': c.file,
  'slogan': c.slogan,
  'about': c.about,
  'attractions': c.attractions,
  'airport': c.airport,
  'gallery': c.gallery,
  'bestTime': c.bestTime,
  'currency': c.currency,
  'language': c.language,
  'timezone': c.timezone,
  'budget': c.budget,
};
City cityFromData(Map<String, dynamic> d) => City(
  d['name'],
  d['country'],
  d['file'],
  d['slogan'],
  d['about'],
  List<String>.from(d['attractions']),
  airport: d['airport'],
  gallery: List<String>.from(d['gallery']),
  bestTime: d['bestTime'],
  currency: d['currency'],
  language: d['language'],
  timezone: d['timezone'],
  budget: d['budget'],
  id: d['id'] ?? d['name'],
);
Map<String, dynamic> bookingData(Booking b) => {
  'origin': b.origin,
  'destination': b.destination,
  'date': b.date.toIso8601String(),
  'returnDate': b.returnDate?.toIso8601String(),
  'roundTrip': b.roundTrip,
  'adults': b.adults,
  'children': b.children,
  'infants': b.infants,
  'cabin': b.cabin,
  'flight': flightData(b.flight),
  'fare': b.fare,
  'reference': b.reference,
  'flightStatus': b.flightStatus,
  'status': b.status,
  'paymentStatus': b.paymentStatus,
  'total': b.total,
  'extras': b.extras.toList(),
  'seats': b.seats.map((key, value) => MapEntry('$key', value)),
  'passengers': b.passengers,
  'history': b.history,
};
Booking bookingFromData(Map<String, dynamic> d) {
  final b = Booking()
    ..origin = d['origin']
    ..destination = d['destination']
    ..date = DateTime.parse(d['date'])
    ..returnDate = DateTime.tryParse(d['returnDate'] ?? '')
    ..roundTrip = d['roundTrip']
    ..adults = d['adults']
    ..children = d['children']
    ..infants = d['infants']
    ..cabin = d['cabin']
    ..flight = flightFromData(Map<String, dynamic>.from(d['flight']))
    ..fare = d['fare']
    ..reference = d['reference']
    ..flightStatus = d['flightStatus']
    ..status = d['status']
    ..paymentStatus = d['paymentStatus']
    ..bookedTotal = d['total'];
  b.extras.addAll(List<int>.from(d['extras']));
  b.seats.addAll(
    (d['seats'] as Map).map((k, v) => MapEntry(int.parse(k), v as String)),
  );
  b.passengers.addAll(
    (d['passengers'] as List).map((p) => Map<String, String>.from(p)),
  );
  b.history.addAll(List<String>.from(d['history']));
  return b;
}
