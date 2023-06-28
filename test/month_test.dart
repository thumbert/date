library test_month;

import 'package:date/date.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void tests() {
  var local = getLocation('America/New_York');

  group('Test Month:', () {
    test('Month.utc constructor', () {
      var month = Month.utc(2019, 10);
      expect(month.start, TZDateTime.utc(2019, 10, 1));
      expect(month.end, TZDateTime.utc(2019, 11, 1));
    });

    test('Create months from year month', () {
      var m = Month(2014, 1, location: UTC);
      var m2 = Month(2014, 1, location: UTC);
      expect(m, m2);
      expect(m.toString(), 'Jan14');
    });

    test('Create months from DateTime', () {
      Month m;
      m = Month.contains(TZDateTime(local, 2014));
      expect([m.year, m.month], [2014, 1]);
      m = Month.contains(TZDateTime(local, 2014, 11));
      expect([m.year, m.month], [2014, 11]);
      m = Month.contains(TZDateTime(local, 2014, 12));
      expect([m.year, m.month], [2014, 12]);
    });

    test('Create month in a different timezone', () {
      var m1 = Month(2017, 1, location: getLocation('America/New_York'));
      expect(m1.location.toString(), 'America/New_York');
      expect(m1.start.toString(), '2017-01-01 00:00:00.000-0500');
      var m2 = Month(2017, 1, location: UTC);
      expect(m2.location.toString(), 'UTC');
      expect(m2.start.toString(), '2017-01-01 00:00:00.000Z');
    });

    test('Next/previous months', () {
      expect(Month(2014, 1, location: UTC).next, Month(2014, 2, location: UTC));
      expect(Month(2014, 1, location: UTC).previous,
          Month(2013, 12, location: UTC));
      expect(
          Month(2014, 1, location: UTC).add(6), Month(2014, 7, location: UTC));
      expect(
          Month(2015, 11, location: UTC).next, Month(2015, 12, location: UTC));
    });

    test('nextN, previousN, upTo', () {
      var m = Month(2017, 3, location: UTC);
      var prevMonths = m.previousN(12);
      expect(prevMonths.length, 12);
      expect(prevMonths.first, Month(2016, 3, location: UTC));
      var nextMonths = m.nextN(12);
      expect(nextMonths.length, 12);
      expect(nextMonths.first, Month(2017, 4, location: UTC));
      var upToMonths = m.upTo(Month(2017, 12, location: UTC));
      expect(upToMonths.length, 10);
      expect(upToMonths.last, Month(2017, 12, location: UTC));
    });

    test('Add/subtract months', () {
      var m1 = Month(2015, 11, location: UTC);
      var m3 = m1.add(1);
      expect(m3.toString(), 'Dec15');
      var m4 = m3.add(1).subtract(1);
      expect('Dec15: (${m4.year}, ${m4.month})', 'Dec15: (2015, 12)');
      expect(m1.subtract(11), Month(2014, 12, location: UTC));
    });

    test('Generate list of months', () {
      var it = Interval(TZDateTime.utc(2015), TZDateTime.utc(2016));
      var months = it.splitLeft((dt) => Month.contains(dt));
      expect(months.length, 12);
    });

    test('Get the days of the month', () {
      var it = Interval(TZDateTime.utc(2015), TZDateTime.utc(2016));
      var days = it
          .splitLeft((dt) => Month.contains(dt))
          .map((m) => m.days().length)
          .toList();
      expect(days, [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]);
    });

    test('Get the number of days in a month', () {
      var it = Interval(TZDateTime.utc(2015), TZDateTime.utc(2016));
      var days = it
          .splitLeft((dt) => Month.contains(dt))
          .map((m) => m.daysInMonth)
          .toList();
      expect(days, [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]);
    });

    test('time ordering for months', () {
      var m1 = Month(2015, 6, location: UTC);
      var m2 = Month(2015, 2, location: UTC);
      expect(m1.isBefore(m2), false);
      expect(m1.isAfter(m2), true);
    });

    test('compareTo months', () {
      var m1 = Month(2015, 6, location: UTC);
      var m2 = Month(2015, 2, location: UTC);
      expect(m1.compareTo(m2), 1);
      expect(m1.compareTo(m1), 0);
    });

    test('month format (default)', () {
      var m1 = Month(2015, 6, location: UTC);
      expect(m1.toString(), 'Jun15');
      expect(m1.toIso8601String(), '2015-06');
    });

    test('month parse Mar19', () {
      var m1 = Month.parse('Mar19', location: local);
      expect(m1, Month(2019, 3, location: local));
    });

    test('month parse (other format)', () {
      var m1 = Month.parse('2017-07', location: local);
      expect(m1, Month(2017, 7, location: local));
    });

    test('get the Mondays in Sep20', () {
      var m = Month(2020, 9, location: UTC);
      var mondays = m.mondays();
      expect(mondays, [
        Date(2020, 9, 7, location: UTC),
        Date(2020, 9, 14, location: UTC),
        Date(2020, 9, 21, location: UTC),
        Date(2020, 9, 28, location: UTC),
      ]);
    });

    test('get the Mondays in Jun20', () {
      var m = Month(2020, 6, location: UTC);
      var mondays = m.mondays();
      expect(mondays, [
        Date(2020, 6, 1, location: UTC),
        Date(2020, 6, 8, location: UTC),
        Date(2020, 6, 15, location: UTC),
        Date(2020, 6, 22, location: UTC),
        Date(2020, 6, 29, location: UTC),
      ]);
    });
  });
}

void main() async {
  initializeTimeZones();
  tests();
}
