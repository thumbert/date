library test.term_test;

import 'package:date/date.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void tests() {
  group('Term tests:', () {
    var location = getLocation('America/New_York');
    test('Term generate', () {
      var years = [2021, 2022, 2023];
      expect(Term.generate(years: years, location: UTC), [
        Term.parse('Jan21-Dec21', UTC),
        Term.parse('Jan22-Dec22', UTC),
        Term.parse('Jan23-Dec23', UTC),
      ]);
      expect(Term.generate(years: years, monthRange: (12, 3), location: UTC), [
        Term.parse('Dec21-Mar22', UTC),
        Term.parse('Dec22-Mar23', UTC),
        Term.parse('Dec23-Mar24', UTC),
      ]);
      expect(
          Term.generate(
              years: years,
              monthRange: (12, 3),
              dayRange: (5, 10),
              location: UTC),
          [
            Term.parse('5Dec21-10Mar22', UTC),
            Term.parse('5Dec22-10Mar23', UTC),
            Term.parse('5Dec23-10Mar24', UTC),
          ]);
    });
    test('with start year', () {
      var nq20 = Term.parse('Jul20-Aug20', location);
      var nq18 = nq20.withStartYear(2018);
      expect(nq18, Term.parse('Jul18-Aug18', location));
      var xh20 = Term.parse('Nov20-Mar21', location);
      var xh18 = xh20.withStartYear(2018);
      expect(xh18, Term.parse('Nov18-Mar19', location));
    });
    test('with start year, for a term ending on 1-Mar', () {
      var t0 = Term.parse('Jan92-Feb92', UTC);
      var t1 = t0.withStartYear(1993);
      expect(t1, Term.parse('Jan93-Feb93', UTC));
    });
    test('term interval', () {
      var term = Term.parse('Jan21-Mar21', location);
      var months = term.interval.splitLeft((dt) => Month.containing(dt));
      expect(months.length, 3);
    });
    test('term is*', () {
      expect(Term.parse('3Jun20', location).isOneDay(), true);
      expect(Term.parse('3Jun20', location).isOneMonth(), false);
      expect(Term.parse('3Jun20', location).isDayRange(), false);
      expect(Term.parse('3Jun20', location).isMonthRange(), false);
      expect(Term.parse('Jun20', location).isOneDay(), false);
      expect(Term.parse('Jun20', location).isOneMonth(), true);
      expect(Term.parse('Jun20', location).isDayRange(), false);
      expect(Term.parse('Jun20', location).isMonthRange(), false);
      expect(Term.parse('Jun20-Jul21', location).isOneDay(), false);
      expect(Term.parse('Jun20-Jul21', location).isOneMonth(), false);
      expect(Term.parse('Jun20-Jul21', location).isDayRange(), false);
      expect(Term.parse('Jun20-Jul21', location).isMonthRange(), true);
      expect(Term.parse('1Jun20-3Jun20', location).isOneDay(), false);
      expect(Term.parse('1Jun20-3Jun20', location).isOneMonth(), false);
      expect(Term.parse('1Jun20-3Jun20', location).isDayRange(), true);
      expect(Term.parse('1Jun20-3Jun20', location).isMonthRange(), false);
    });
    test('number of days in term', () {
      expect(Term.parse('1Apr24', UTC).dayCount(), 1);
      expect(Term.parse('1Apr24-10Apr24', UTC).dayCount(), 10);
      expect(Term.parse('Jan24', UTC).dayCount(), 31);
      expect(Term.parse('Jan24-Feb24', UTC).dayCount(), 60);
    });
    test('toString() a Cal', () {
      expect(Term.parse('Jan23-Dec23', location).toString(), 'Cal 23');
    });
    test('toString() a Quarter', () {
      expect(Term.parse('Jan23-Mar23', location).toString(), 'Q1, 23');
      expect(Term.parse('Apr23-Jun23', location).toString(), 'Q2, 23');
      expect(Term.parse('Jul23-Sep23', location).toString(), 'Q3, 23');
      expect(Term.parse('Oct23-Dec23', location).toString(), 'Q4, 23');
    });
    test('prettyTerm tests', () {
      expect(prettyTerm(Date(2018, 1, 1, location: UTC)), '1Jan18');
      expect(prettyTerm(Month(2018, 1, location: UTC)), 'Jan18');
      expect(
          prettyTerm(Interval(
              TZDateTime.utc(2018, 1, 1), TZDateTime.utc(2018, 1, 21))),
          '1Jan18-20Jan18');
      expect(
          prettyTerm(Interval(
              TZDateTime.utc(2018, 1, 3), TZDateTime.utc(2018, 5, 21))),
          '3Jan18-20May18');
      expect(
          prettyTerm(
              Interval(TZDateTime.utc(2018, 1), TZDateTime.utc(2018, 5))),
          'Jan18-Apr18');
    });
  });
}

void main() async {
  initializeTimeZones();
  tests();
}
