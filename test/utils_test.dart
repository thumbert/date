library utils_test;

import 'package:date/date.dart';
import 'package:test/test.dart';

void tests() {
  group('utils tests', () {
    test('day of the year', () {
      expect(dayOfYear(2019, 1, 1), 1);
      expect(dayOfYear(2019, 2, 1), 32);
      expect(dayOfYear(2020, 4, 20), 111);
    });
  });
}

void main() {
  tests();
}