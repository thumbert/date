library test.term_test;

import 'package:date/date.dart';
import 'package:date/src/term.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void tests() {
  group('Term tests:', () {
    var location = getLocation('America/New_York');
    test('with start year', () {
      var nq20 = Term.parse('Jul20-Aug20', location);
      var nq18 = nq20.withStartYear(2018);
      expect(nq18, Term.parse('Jul18-Aug18', location));
      var xh20 = Term.parse('Nov20-Mar21', location);
      var xh18 = xh20.withStartYear(2018);
      expect(xh18, Term.parse('Nov18-Mar19', location));
    });
    test('term interval', () {
      var term = Term.parse('Jan21-Mar21', location);
      var months = term.interval.splitLeft((dt) => Month.fromTZDateTime(dt));
      expect(months.length, 3);
    });
    test('term is*', (){
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
  });
}

void main() async {
  await initializeTimeZones();
  tests();
}