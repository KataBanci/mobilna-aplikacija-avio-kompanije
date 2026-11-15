import '../models/booking.dart';
import 'calendar_stub.dart'
    if (dart.library.io) 'calendar_native.dart'
    if (dart.library.js_interop) 'calendar_web.dart'
    as platform;

String calendarContents(Booking b) {
  final time = b.flight.departure.split(':');
  final start = DateTime(
    b.date.year,
    b.date.month,
    b.date.day,
    int.parse(time[0]),
    int.parse(time[1]),
  );
  String stamp(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}00';
  final timezone = {
    'BEG': 'Europe/Belgrade',
    'FCO': 'Europe/Rome',
    'LHR': 'Europe/London',
    'CDG': 'Europe/Paris',
    'VIE': 'Europe/Vienna',
  }[b.code(b.origin)]!;
  final duration = b.flight.direct ? 115 : 275;
  return [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//AirVista//Rezervacije//SR',
    'CALSCALE:GREGORIAN',
    'BEGIN:VEVENT',
    'UID:${b.reference}@airvista.example',
    'DTSTAMP:${stamp(DateTime.now().toUtc())}Z',
    'DTSTART;TZID=$timezone:${stamp(start)}',
    'DTEND;TZID=$timezone:${stamp(start.add(Duration(minutes: duration)))}',
    'SUMMARY:AirVista - ${b.route}',
    'LOCATION:${b.origin}',
    'DESCRIPTION:Probna rezervacija ${b.reference} - ${b.flight.number}',
    'BEGIN:VALARM',
    'TRIGGER:-PT2H',
    'ACTION:DISPLAY',
    'DESCRIPTION:Vreme je za putovanje',
    'END:VALARM',
    'END:VEVENT',
    'END:VCALENDAR',
    '',
  ].join('\r\n');
}

Future<String> exportCalendar(Booking b) =>
    platform.saveCalendar(calendarContents(b), 'AirVista-${b.reference}.ics');
