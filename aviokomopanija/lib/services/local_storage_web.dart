import 'dart:js_interop';

@JS('window.localStorage')
external _Storage get _storage;

extension type _Storage(JSObject _) implements JSObject {
  external JSString? getItem(JSString key);
  external void setItem(JSString key, JSString value);
}

Future<String?> readLocalData() async =>
    _storage.getItem('airvista-data-v1'.toJS)?.toDart;
Future<void> writeLocalData(String value) async =>
    _storage.setItem('airvista-data-v1'.toJS, value.toJS);
