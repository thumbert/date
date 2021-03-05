library quarter_test;

import 'package:date/date.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void tests() {
  var local = getLocation('America/New_York');
  group('Test Quarter:', () {
    test('Constructor from year quarter', () {
      var m = Quarter(2014, 1, location: UTC);
      var m2 = Quarter(2014, 1, location: UTC);
      expect(m, m2);
      expect(m.toString(), '2014-Q1');
    });

    test('Create quarters from DateTime', () {
      Quarter m;
      m = Quarter.fromTZDateTime(TZDateTime(local, 2014));
      expect([m.year, m.quarter], [2014, 1]);
      m = Quarter.fromTZDateTime(TZDateTime(local, 2014, 4));
      expect([m.year, m.quarter], [2014, 2]);
      m = Quarter.fromTZDateTime(TZDateTime(local, 2014, 10));
      expect([m.year, m.quarter], [2014, 4]);
    });

    test('Create quarter in a different timezone', () {
      var m1 = Quarter(2017, 1, location: getLocation('America/New_York'));
      expect(m1.location.toString(), 'America/New_York');
      expect(m1.start.toString(), '2017-01-01 00:00:00.000-0500');
      var m2 = Quarter(2017, 1, location: UTC);
      expect(m2.location.toString(), 'UTC');
      expect(m2.start.toString(), '2017-01-01 00:00:00.000Z');
    });

    test('start/end of quarter', () {
      var q3 = Quarter(2016, 3, location: UTC);
      expect(q3.start, TZDateTime.utc(2016, 7));
      expect(q3.end, TZDateTime.utc(2016, 10));
      var q4 = Quarter(2016, 4, location: UTC);
      expect(q4.start, TZDateTime.utc(2016, 10));
      expect(q4.end, TZDateTime.utc(2017, 1));
    });

    test('Next/previous quarter', () {
      expect(Quarter(2014, 1, location: UTC).next,
          Quarter(2014, 2, location: UTC));
      expect(Quarter(2014, 1, location: UTC).previous,
          Quarter(2013, 4, location: UTC));
      expect(Quarter(2014, 1, location: UTC).add(6),
          Quarter(2014, 7, location: UTC));
      expect(Quarter(2015, 11, location: UTC).next,
          Quarter(2015, 12, location: UTC));
    });

    test('Add/subtract quarters', () {
      var m1 = Quarter(2015, 4, location: UTC);
      var m3 = m1.add(1);
      expect(m3.toString(), '2016-Q1');
      var m4 = m3.add(1).subtract(1);
      expect(m4, m3);
      expect(m1.add(5), Quarter(2017, 1, location: UTC));
      expect(m1.subtract(5), Quarter(2014, 3, location: UTC));
    });

    test('Generate list of quarters', () {
      var it = Interval(TZDateTime.utc(2015), TZDateTime.utc(2017));
      var quarters = it.splitLeft((dt) => Quarter.fromTZDateTime(dt));
      expect(quarters.length, 8);
    });

    test('time ordering for quarters', () {
      var m1 = Quarter(2015, 4, location: UTC);
      var m2 = Quarter(2015, 2, location: UTC);
      expect(m1.isBefore(m2), false);
      expect(m1.isAfter(m2), true);
    });

    test('compareTo quarters', () {
      var m1 = Quarter(2015, 3, location: UTC);
      var m2 = Quarter(2015, 2, location: UTC);
      expect(m1.compareTo(m2), 1);
      expect(m1.compareTo(m1), 0);
    });

    test('format quarter (default)', () {
      var m1 = Quarter(2015, 3, location: UTC);
      expect(m1.toString(), '2015-Q3');
      expect(m1.toString(fmt: Quarter.format), 'Q3, 2015');
    });

    test('quarter parse', () {
      var m1 = Quarter.parse('2017-Q2', local);
      expect(m1, Quarter(2017, 2, location: local));
    });
  });
}

void main() async {
  initializeTimeZones();
  tests();
}
