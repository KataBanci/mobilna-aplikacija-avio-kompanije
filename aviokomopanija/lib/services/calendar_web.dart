import 'dart:js_interop';

@JS('document.createElement')
external JSObject createElement(String tag);

extension type CalendarAnchor(JSObject _) implements JSObject {
  external set href(String value);
  external set download(String value);
  external void click();
}

Future<String> saveCalendar(String contents, String filename) async {
  final anchor = CalendarAnchor(createElement('a'));
  anchor.href =
      'data:text/calendar;charset=utf-8,${Uri.encodeComponent(contents)}';
  anchor.download = filename;
  anchor.click();
  return 'Preuzimanje je pokrenuto. Otvorite .ics datoteku u svom kalendaru.';
}
