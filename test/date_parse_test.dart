library test.date_parse_test;

import 'package:date/date.dart';
import 'package:date/src/date_parse.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void tests() {
  group('Date parse:', () {
    test('A malformed input', () {
      expect(tryParseDate('29May2a'), null);
    });
    test('A date: 1jan17, 1-Jan-17, 1 Mar 2017, 1Mar2017', () {
      expect(parseDate('1jan17'), Date(2017, 1, 1, location: UTC));
      expect(parseDate('1-Jan-17'), Date(2017, 1, 1, location: UTC));
      expect(parseDate('1 Mar 2017'), Date(2017, 3, 1, location: UTC));
      expect(parseDate('1Mar2017'), Date(2017, 3, 1, location: UTC));
    });
    test('A date: 1/1/2017, 3/21/2017, 11/1/2017', () {
      expect(parseDate('1/1/2017'), Date(2017, 1, 1, location: UTC));
      expect(parseDate('3/21/2017'), Date(2017, 3, 21, location: UTC));
      expect(parseDate('11/1/2017'), Date(2017, 11, 1, location: UTC));
    });
    test('A date in ISO format: 2018-01-05, 20180105', () {
      expect(parseDate('2018-01-05'), Date(2018, 1, 5, location: UTC));
      expect(parseDate('20180105'), Date(2018, 1, 5, location: UTC));
    });
  });
}

void main() async {
  initializeTimeZones();
  tests();
}
