library test.week_test;

import 'package:date/date.dart';
import 'package:date/src/week.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void tests() {
  group('Week tests:', () {
    var location = getLocation('US/Eastern');
    test('week from TZDateTime, 2019-12-30 00:00:00', () {
      var dt = TZDateTime(location, 2019, 12, 30);
      var week = Week.fromTZDateTime(dt);
      expect(week, Week.parse('2020-W01', location));
    });

    test('weekStart', () {
      var dt = Week.weekStart(2020, 1, UTC);
      expect(dt, TZDateTime.utc(2019, 12, 30));
    });
    test('week from TZDateTime, 2019-01-01 00:00:00', () {
      var dt = TZDateTime(location, 2019);
      var week = Week.fromTZDateTime(dt);
      expect(week, Week.parse('2019-W01', location));
    });
    test('week 1, 2019', () {
      var week1 = Week(2019, 1, location);
      expect(week1.start, TZDateTime(location, 2018, 12, 31));
      expect(week1.end, TZDateTime(location, 2019, 1, 7));
    });
    test('week 1, 2020', () {
      var week1 = Week(2020, 1, location);
      expect(week1.start, TZDateTime(location, 2019, 12, 30));
      expect(week1.end, TZDateTime(location, 2020, 1, 6));
    });
    test('week 4, 2020', () {
      var week4 = Week(2020, 4, location);
      expect(week4.start, TZDateTime(location, 2020, 1, 20));
      expect(week4.end, TZDateTime(location, 2020, 1, 27));
    });
    test('week 53, 2020', () {
      var week53 = Week(2020, 53, location);
      expect(week53.start, TZDateTime(location, 2020, 12, 28));
      expect(week53.end, TZDateTime(location, 2021, 1, 4));
    });
    test('week 1, 2021', () {
      var week1 = Week(2021, 1, location);
      expect(week1.start, TZDateTime(location, 2021, 1, 4));
      expect(week1.end, TZDateTime(location, 2021, 1, 11));
    });
    test('weekOfYear calculation', () {
      expect(Week.weekOfYear(TZDateTime(location, 2021, 1, 3)), 53);
      expect(Week.weekOfYear(TZDateTime(location, 2020, 12, 29)), 53);
      expect(Week.weekOfYear(TZDateTime(location, 2019, 12, 30)), 1);
      expect(Week.weekOfYear(TZDateTime(location, 2020, 1, 3)), 1);
      expect(Week.weekOfYear(TZDateTime(location, 2021, 1, 4)), 1);
      expect(Week.weekOfYear(TZDateTime(location, 2008, 12, 28)), 52);
      expect(Week.weekOfYear(TZDateTime(location, 2008, 12, 29)), 1);
    });
    test('toString', (){
      expect(Week(2020,1,location).toString(), '2020-W01');
      expect(Week(2020,53,location).toString(), '2020-W53');
    });
    test('equality', () {
      expect(Week(2020, 1, UTC), Week(2020, 1, UTC));
    });
    test('next and previous week', () {
      expect(Week(2020, 1, UTC).next, Week(2020, 2, UTC));
      expect(Week(2020, 1, UTC).previous, Week(2019, 52, UTC));
      expect(Week(2021, 1, UTC).previous, Week(2020, 53, UTC));
    });
    test('before and after', (){
      expect(Week(2020, 2, UTC).isAfter(Week(2020, 1, UTC)), true);
      expect(Week(2020, 2, UTC).isBefore(Week(2020, 1, UTC)), false);
      expect(Week(2020, 1, UTC).isBefore(Week(2020, 1, UTC)), false);
      expect(Week(2020, 1, UTC).isBefore(Week(2020, 2, UTC)), true);
    });
    test('week parse', () {
      expect(Week.parse('2020-W01', UTC), Week(2020, 1, UTC));
      expect(Week.parse('2020-W24', UTC), Week(2020, 24, UTC));
      expect(Week.parse('2020W01', UTC), Week(2020, 1, UTC));
    });
    test('number of hours in 2019-W01', () {
      var term = Week.parse('2019-W01', location);
      var hours = term.splitLeft((dt) => Hour.beginning(dt));
      expect(hours.length, 168);
    });
  });
}


void main() async {
  await initializeTimeZones();
  tests();
}