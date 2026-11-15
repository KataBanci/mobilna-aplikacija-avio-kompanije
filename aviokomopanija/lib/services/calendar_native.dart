import 'dart:io';

Future<String> saveCalendar(String contents, String filename) async {
  final directory = await Directory.systemTemp.createTemp('airvista_');
  final file = File('${directory.path}${Platform.pathSeparator}$filename');
  await file.writeAsString(contents, flush: true);
  return 'Sačuvano: ${file.path}\nOtvorite datoteku u aplikaciji za kalendar.';
}
