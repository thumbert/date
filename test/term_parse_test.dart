library test.term_parse_test;

import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';
import 'package:date/src/interval.dart';
import 'package:date/src/month.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/term.dart';
import 'package:date/src/term_parse.dart';

void parseTermTest() {
  group('Term Parse:', () {
    test('A month: jan 17, Jan17, Mar 2017, JAN 17, April 17, December 17', () {
      expect(() => parseTerm('Jan201'), throwsArgumentError);
      expect(parseTerm('Mar 2017'), Month(2017, 3, location: UTC));
      expect(parseTerm('Jan17'), Month(2017, 1, location: UTC));
      expect(parseTerm('Jan 17'), Month(2017, 1, location: UTC));
      expect(parseTerm('JAN 17'), Month(2017, 1, location: UTC));
      expect(parseTerm('April 17'), Month(2017, 4, location: UTC));
      expect(parseTerm('December 17'), Month(2017, 12, location: UTC));
    });
    test('A month: F17, G17, .. Z17', () {
      expect(parseTerm('F17'), Month(2017, 1, location: UTC));
      expect(parseTerm('G17'), Month(2017, 2, location: UTC));
      expect(parseTerm('H17'), Month(2017, 3, location: UTC));
      expect(parseTerm('N17'), Month(2017, 7, location: UTC));
      expect(parseTerm('Q17'), Month(2017, 8, location: UTC));
      expect(parseTerm('U17'), Month(2017, 9, location: UTC));
      expect(parseTerm('V17'), Month(2017, 10, location: UTC));
      expect(parseTerm('X17'), Month(2017, 11, location: UTC));
      expect(parseTerm('Z17'), Month(2017, 12, location: UTC));
      expect(() => parseTerm('Z 17'), throwsArgumentError);
      expect(() => parseTerm('Z217'), throwsArgumentError);
    });
    test('An ISO month: 2017-09', () {
      expect(parseTerm('2017-09'), Month(2017, 9, location: UTC));
    });
    test('A day: 3 jan 17, 03 jan 17', () {
      expect(parseTerm('3 jan 17'), Date(2017, 1, 3, location: UTC));
      expect(parseTerm('03 jan 17'), Date(2017, 1, 3, location: UTC));
      expect(parseTerm('3jan 17'), Date(2017, 1, 3, location: UTC));
    });
    test('A quarter: "Q1,17", "Q1 17", "Q1, 2017", "Q1 2017"', () {
      expect(parseTerm('Q1,17'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2017, 4)));
      expect(parseTerm('Q1, 2017'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2017, 4)));
      expect(parseTerm('Q1 2017'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2017, 4)));
      expect(parseTerm('Q1 17'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2017, 4)));
      expect(() => parseTerm('Q1 201'), throwsArgumentError);
    });
    test('A calendar year: 2017, CAL2017, Cal 2017, Cal17', () {
      expect(parseTerm('2017'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2018)));
      expect(parseTerm('CAL2017'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2018)));
      expect(parseTerm('Cal 2017'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2018)));
      expect(parseTerm('Cal17'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2018)));
    });
    test('A relative token: -3d', () {
      var today = Date.today(location: UTC);
      var interval = parseTerm('-3d');
      var start = today.subtract(3).start;
      var exp = Interval(start, today.end);
      expect(interval, exp);
    });
    test('A relative token: -2m', () {
      var today = Date.today(location: UTC);
      var interval = parseTerm('-2m');
      var start = today.subtract(61).start;
      var exp = Interval(start, today.end);
      expect(interval, exp);
    });
    test('A relative token: -1y', () {
      var today = Date.today(location: UTC);
      var interval = parseTerm('-1y');
      var start = today.subtract(365).start;
      var exp = Interval(start, today.end);
      expect(interval, exp);
    });
    test('A relative token: -1Y', () {
      var today = Date.today(location: UTC);
      var interval = parseTerm('-1Y');
      var start = today.subtract(365).start;
      var exp = Interval(start, today.end);
      expect(interval, exp);
    });
    test('A relative token: -1y+1y', () {
      var today = Date.today(location: UTC);
      var interval = parseTerm('-1y+1y');
      var start = today.subtract(365).start;
      var end = today.add(365).end;
      var exp = Interval(start, end);
      expect(interval, exp);
    });
    test('A relative token: -1d+3d', () {
      var today = Date.today(location: UTC);
      var interval = parseTerm('-1d+3d');
      var start = today.subtract(1).start;
      var end = today.add(3).end;
      var exp = Interval(start, end);
      expect(interval, exp);
    });
    test('A month range: jan17-feb17, jan17 - feb17, jan17-Feb17', () {
      expect(parseTerm('jan17-feb17'),
          Interval(TZDateTime.utc(2017, 1), TZDateTime.utc(2017, 3)));
      expect(parseTerm('jan17 - feb17'),
          Interval(TZDateTime.utc(2017, 1), TZDateTime.utc(2017, 3)));
      expect(parseTerm('jan17-Feb17'),
          Interval(TZDateTime.utc(2017, 1), TZDateTime.utc(2017, 3)));
    });
    test('A wrong month range: jan23-dec22 should throw', () {
      expect(() => parseTerm('jan23-dec22'), throwsArgumentError);
    });
    test('An ISO day: 2020-07-03, 20200703', () {
      expect(parseTerm('20200703'),
          Interval(TZDateTime.utc(2020, 7, 3), TZDateTime.utc(2020, 7, 4)));
      expect(parseTerm('2020-07-03'),
          Interval(TZDateTime.utc(2020, 7, 3), TZDateTime.utc(2020, 7, 4)));
      expect(() => parseTerm('2020-0703'), throwsArgumentError);
      expect(() => parseTerm('202007-03'), throwsArgumentError);
    });
    test('A day range: 1jan17-3feb17', () {
      expect(parseTerm('1jan17-3feb17'),
          Interval(TZDateTime.utc(2017, 1), TZDateTime.utc(2017, 2, 4)));
    });
    test('A day range in America/New_York timezone: 1jan17-3feb17', () {
      var location = getLocation('America/New_York');
      expect(
          parseTerm('1jan17-3feb17', tzLocation: location),
          Interval(
              TZDateTime(location, 2017, 1), TZDateTime(location, 2017, 2, 4)));
    });
    test('A wrong day range: 3jan23-1Jan23 should throw', () {
      expect(() => parseTerm('3Jan23-1Jan23'), throwsArgumentError);
    });
    test('A month code range F19-G19', () {
      var location = getLocation('America/New_York');
      var term = Term.parse('F19-G19', location);
      expect(
          term.interval,
          Interval(
              TZDateTime(location, 2019, 1), TZDateTime(location, 2019, 3)));
    });
    test('A wrong month code range: U23-K23 should throw', () {
      expect(() => parseTerm('U23-K23'), throwsArgumentError);
    });
  });
}

void main() async {
  initializeTimeZones();

  //print(TermParser().parse('Jan 17').value);

  /// Don't know how to test relative terms yet
//  print(TermParser().parse('-1m').value);
//  print(TermParser().parse('-1y').value);

  parseTermTest();
}
