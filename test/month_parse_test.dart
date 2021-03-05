library test.month_parse_test;

import 'dart:io';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';
import 'package:date/src/month.dart';
import 'package:date/src/month_parse.dart';
import 'package:timezone/timezone.dart';

void tests() {
  group('Month Parse:', () {
    test('A month: jan 17, Mar 2017, JAN 17, April 17, December 17', () {
      expect(parseMonth('Jan 17'), Month(2017, 1, location: UTC));
      expect(parseMonth('Mar 2017'), Month(2017, 3, location: UTC));
      expect(parseMonth('JAN 17'), Month(2017, 1, location: UTC));
      expect(parseMonth('April 17'), Month(2017, 4, location: UTC));
      expect(parseMonth('December 17'), Month(2017, 12, location: UTC));
    });
    test('A month: F17, G17, .. Z17', () {
      expect(parseMonth('F17'), Month(2017, 1, location: UTC));
    });
    test('A month in ISO format: 2018-01, 201801', () {
      expect(parseMonth('2018-01'), Month(2018, 1, location: UTC));
      expect(parseMonth('201801'), Month(2018, 1, location: UTC));
    });
  });
}

void main() async {
  initializeTimeZones();
  tests();
}
