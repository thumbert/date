library test.term_parse_test;


import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';
import 'package:date/src/interval.dart';
import 'package:date/src/month.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/term.dart';
import 'package:date/src/term_parse.dart';

void parseTermTest() {
  group('Term Parse:', () {
    test('A month: jan 17, Mar 2017, JAN 17, April 17, December 17', () {
      expect(parseTerm('Jan 17'), Month(2017, 1));
      expect(parseTerm('Mar 2017'), Month(2017, 3));
      expect(parseTerm('JAN 17'), Month(2017, 1));
      expect(parseTerm('April 17'), Month(2017, 4));
      expect(parseTerm('December 17'), Month(2017, 12));
    });
    test('A month: F17, G17, .. Z17', () {
      expect(parseTerm('F17'), Month(2017, 1));
    });
    test('A day: 3 jan 17, 03 jan 17', () {
      expect(parseTerm('3 jan 17'), Date(2017, 1, 3));
      expect(parseTerm('03 jan 17'), Date(2017, 1, 3));
      expect(parseTerm('3jan 17'), Date(2017, 1, 3));
    });
    test('A quarter: Q1,17', () {
      expect(parseTerm('Q1,17'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2017, 4)));
    });
    test('A quarter: Q1, 2017', () {
      expect(parseTerm('Q1, 2017'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2017, 4)));
    });
    test('A calendar year: CAL2017, Cal 2017', () {
      expect(parseTerm('CAL2017'),
          Interval(TZDateTime.utc(2017), TZDateTime.utc(2018)));
      expect(parseTerm('Cal 2017'),
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
      expect(
          parseTerm('jan17-feb17'),
          Interval(
              TZDateTime.utc(2017, 1), TZDateTime.utc(2017, 3)));
      expect(
          parseTerm('jan17 - feb17'),
          Interval(
              TZDateTime.utc(2017, 1), TZDateTime.utc(2017, 3)));
      expect(
          parseTerm('jan17-Feb17'),
          Interval(
              TZDateTime.utc(2017, 1), TZDateTime.utc(2017, 3)));
    });
    test('A day range: 1jan17-3feb17', () {
      expect(
          parseTerm('1jan17-3feb17'),
          Interval(
              TZDateTime.utc(2017, 1), TZDateTime.utc(2017, 2, 4)));
    });
    test('A day range in America/New_York timezone: 1jan17-3feb17', () {
      var location = getLocation('America/New_York');
      expect(
          parseTerm('1jan17-3feb17', tzLocation: location),
          Interval(
              TZDateTime(location, 2017, 1), TZDateTime(location, 2017, 2, 4)));
    });
    test('prettyTerm tests', () {
      expect(prettyTerm(Date(2018, 1, 1)), '1Jan18');
      expect(prettyTerm(Month(2018, 1)), 'Jan18');
      expect(
          prettyTerm(Interval(
              TZDateTime.utc(2018, 1, 1), TZDateTime.utc(2018, 1, 21))),
          '1Jan18-20Jan18');
      expect(
          prettyTerm(Interval(
              TZDateTime.utc(2018, 1, 3), TZDateTime.utc(2018, 5, 21))),
          '3Jan18-20May18');
      expect(
          prettyTerm(Interval(
              TZDateTime.utc(2018,1), TZDateTime.utc(2018,5))),
          'Jan18-Apr18');
    });
  });
}

void main() async {
  await initializeTimeZone();

  //print(TermParser().parse('Jan 17').value);

  /// Don't know how to test relative terms yet
//  print(TermParser().parse('-1m').value);
//  print(TermParser().parse('-1y').value);

  await parseTermTest();
}
