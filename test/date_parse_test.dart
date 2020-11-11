library test.date_parse_test;

import 'package:date/date.dart';
import 'package:date/src/date_parse.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';

void tests() {
  group('Date parse:', () {
    test('A date: 1jan17, 1-Jan-17, 1 Mar 2017, 1Mar2017', () {
      expect(parseDate('1jan17'), Date(2017, 1, 1));
      expect(parseDate('1-Jan-17'), Date(2017, 1, 1));
      expect(parseDate('1 Mar 2017'), Date(2017, 3, 1));
      expect(parseDate('1Mar2017'), Date(2017, 3, 1));
    });
    test('A date: 1/1/2017, 3/21/2017, 11/1/2017', () {
      expect(parseDate('1/1/2017'), Date(2017, 1, 1));
      expect(parseDate('3/21/2017'), Date(2017, 3, 21));
      expect(parseDate('11/1/2017'), Date(2017, 11, 1));
    });
    test('A date in ISO format: 2018-01-05, 20180105', () {
      expect(parseDate('2018-01-05'), Date(2018, 1, 5));
      expect(parseDate('20180105'), Date(2018, 1, 5));
    });
  });
}

void main() async {
  await initializeTimeZones();
  await tests();
}
