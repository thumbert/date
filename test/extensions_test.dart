library test.extension_test;

import 'package:test/test.dart';
import 'package:timezone/timezone.dart';
import 'package:date/src/datetime_ext.dart';

void tests() {
  group('TZDateTime extension tests:', () {
    test('num.fromExcel() returns TZDateTime', () {
      var x = 44186.42034722222;
      var out = x.fromExcelDateTime();
      expect(out, TZDateTime.utc(2020, 12, 21, 10, 5, 18));
    });
  });
}

void main() {
  tests();
}
