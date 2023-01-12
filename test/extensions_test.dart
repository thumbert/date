library test.extension_test;

import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';
import 'package:date/src/datetime_ext.dart';

void tests() {
  group('TZDateTime extension tests:', () {
    test('num.fromExcel() returns TZDateTime', () {
      var x = 44186.42034722222;
      var out = x.fromExcelDateTime();
      expect(out, TZDateTime.utc(2020, 12, 21, 10, 5, 18));
    });
    test('TZDateTime copyWith() extension', () {
      var location = getLocation('America/New_York');
      var dt = TZDateTime(location, 2023);
      expect(dt.copyWith(year: 2022), TZDateTime(location, 2022));
      expect(dt.copyWith(location: UTC, year: 2022), TZDateTime(UTC, 2022));
      expect(dt.copyWith(location: UTC, year: 2022, month: 3),
          TZDateTime(UTC, 2022, 3));
      expect(dt.copyWith(location: UTC, year: 2022, month: 3, day: 15),
          TZDateTime(UTC, 2022, 3, 15));
      expect(dt.copyWith(location: UTC, year: 2022, month: 3, day: 15, hour: 8),
          TZDateTime(UTC, 2022, 3, 15, 8));
      expect(
          dt.copyWith(
              location: UTC,
              year: 2022,
              month: 3,
              day: 15,
              hour: 8,
              minute: 25),
          TZDateTime(UTC, 2022, 3, 15, 8, 25));
      expect(
          dt.copyWith(
              location: UTC,
              year: 2022,
              month: 3,
              day: 15,
              hour: 8,
              minute: 25,
              second: 10),
          TZDateTime(UTC, 2022, 3, 15, 8, 25, 10));
    });
  });
}

void main() {
  initializeTimeZones();
  tests();
}
