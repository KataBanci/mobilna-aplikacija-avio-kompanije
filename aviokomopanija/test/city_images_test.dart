import 'dart:ui' as ui;

import 'package:aviokomopanija/models/city.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Sve fotografije destinacija mogu da se učitaju i dekodiraju', () async {
    for (final city in cities) {
      final data = await rootBundle.load(city.image);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(0), reason: city.image);
      expect(frame.image.height, greaterThan(0), reason: city.image);
      frame.image.dispose();
      codec.dispose();
    }
  });
}
