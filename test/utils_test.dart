library utils_test;

import 'package:date/date.dart';
import 'package:test/test.dart';

void tests() {
  group('utils tests:', () {
    test('day of the year', () {
      expect(dayOfYear(2019, 1, 1), 1);
      expect(dayOfYear(2019, 2, 1), 32);
      expect(dayOfYear(2020, 4, 20), 111);
    });
    test('beginning of week', () {
      expect(isBeginningOfWeek(DateTime(2020, 4, 20)), true);
      expect(isBeginningOfWeek(DateTime(2020, 4, 22)), false);
    });
  });
}

void main() {
  tests();
}