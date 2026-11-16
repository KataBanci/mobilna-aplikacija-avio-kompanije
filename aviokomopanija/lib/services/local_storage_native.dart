import 'dart:io';

File get _file {
  final root =
      Platform.environment['LOCALAPPDATA'] ??
      Platform.environment['HOME'] ??
      Directory.systemTemp.path;
  return File('$root/airvista/airvista-data.json');
}

Future<String?> readLocalData() async {
  final file = _file;
  return await file.exists() ? file.readAsString() : null;
}

Future<void> writeLocalData(String value) async {
  final file = _file;
  await file.parent.create(recursive: true);
  final temp = File('${file.path}.tmp');
  await temp.writeAsString(value, flush: true);
  await temp.rename(file.path);
}
