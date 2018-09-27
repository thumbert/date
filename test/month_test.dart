library test_month;

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';
import 'package:date/src/month.dart';
import 'package:date/src/time_iterable.dart';


testMonth() {
  Location local = getLocation('US/Eastern');

  group("Test Month:", () {
    test("Create months from year month", () {
      Month m = new Month(2014, 1);
      Month m2 = new Month(2014, 1);
      expect(m, m2);
      expect(m.toString(), "Jan14");
    });

    test("Create months from DateTime", () {
      Month m;
      m = new Month.fromTZDateTime(new TZDateTime(local, 2014));
      expect([m.year, m.month], [2014, 1]);
      m = new Month.fromTZDateTime(new TZDateTime(local, 2014, 11));
      expect([m.year, m.month], [2014, 11]);
      m = new Month.fromTZDateTime(new TZDateTime(local, 2014, 12));
      expect([m.year, m.month], [2014, 12]);
    });

    test('Create month in a different timezone', (){
      Month m1 = new Month(2017, 1, location: getLocation('US/Eastern'));
      expect(m1.location.toString(), 'US/Eastern');
      expect(m1.start.toString(), '2017-01-01 00:00:00.000-0500');
      Month m2 = new Month(2017, 1);
      expect(m2.location.toString(), 'UTC');
      expect(m2.start.toString(), '2017-01-01 00:00:00.000Z');
    });

    test("Next/previous months", () {
      expect(new Month(2014, 1).next, new Month(2014, 2));
      expect(new Month(2014, 1).previous, new Month(2013, 12));
      expect(new Month(2014, 1).add(6), new Month(2014, 7));
      expect(new Month(2015, 11).next, new Month(2015, 12));
    });

    test("Add/subtract months", () {
      Month m1 = new Month(2015, 11);
      Month m3 = m1.add(1);
      expect(m3.toString(), 'Dec15');
      Month m4 = m3.add(1).subtract(1);
      expect("Dec15: (${m4.year}, ${m4.month})", "Dec15: (2015, 12)");
      expect(m1.subtract(11), new Month(2014, 12));
    });

    test("Generate list of months", () {
      TimeIterable<Month> it = new TimeIterable(new Month(2015,1), new Month(2015,12));
      expect(it.length, 12);
    });

    test('Date iterator', () {
      Month m = new Month(2015, 1);
      TimeIterator it = m.dateIterator;
      it.moveNext();
      expect(it.current, m.startDate);
    });

    test('Get the days of the month', () {
      TimeIterable<Month> it = new TimeIterable(new Month(2015,1), new Month(2015,12));
      List days = it.map((Month m) => m.days().length).toList();
      expect(days, [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]);
    });

    test('compare months', (){
      Month m1 = new Month(2015,6);
      Month m2 = new Month(2015,2);
      expect(m1.isBefore(m2), false);
      expect(m1.isAfter(m2), true);
    });

    test('month format (default)', () {
      Month m1 = new Month(2015,6);
      expect(m1.toString(), 'Jun15');
      expect(m1.toIso8601String(), '2015-06');
    });

    test('month parse (other format)', () {
      DateFormat isoFmt = new DateFormat('yyyy-MM');
      Month m1 = Month.parse('2017-07', fmt: isoFmt, location: local);
      expect(m1, Month(2017, 7, location: local));
    });


  });
}

main() async {
  Map env = Platform.environment;
  String tzdb = env['HOME'] + '/.pub-cache/hosted/pub.dartlang.org/timezone-0.4.3/lib/data/2015b_all.tzf';
  await initializeTimeZone(tzdb);

  await testMonth();
}
