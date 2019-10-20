library test_month;

import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';
import 'package:date/src/month.dart';
import 'package:date/src/interval.dart';


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
      expect(Month(2014, 1).next, Month(2014, 2));
      expect(Month(2014, 1).previous, Month(2013, 12));
      expect(Month(2014, 1).add(6), Month(2014, 7));
      expect(Month(2015, 11).next, Month(2015, 12));
    });

    test('nextN, previousN, upTo', () {
      var m = Month(2017, 3);
      var prevMonths = m.previousN(12);
      expect(prevMonths.length, 12);
      expect(prevMonths.first, Month(2016, 3));
      var nextMonths = m.nextN(12);
      expect(nextMonths.length, 12);
      expect(nextMonths.first, Month(2017, 4));
      var upToMonths = m.upTo(Month(2017, 12));
      expect(upToMonths.length, 10);
      expect(upToMonths.last, Month(2017, 12));
    });

    test("Add/subtract months", () {
      Month m1 = Month(2015, 11);
      Month m3 = m1.add(1);
      expect(m3.toString(), 'Dec15');
      Month m4 = m3.add(1).subtract(1);
      expect("Dec15: (${m4.year}, ${m4.month})", "Dec15: (2015, 12)");
      expect(m1.subtract(11), Month(2014, 12));
    });

    test("Generate list of months", () {
      var it = Interval(TZDateTime.utc(2015), TZDateTime.utc(2016));
      var months = it.splitLeft((dt) => Month.fromTZDateTime(dt));
      expect(months.length, 12);
    });

    test('Get the days of the month', () {
      var it = Interval(TZDateTime.utc(2015), TZDateTime.utc(2016));
      var days = it.splitLeft((dt) => Month.fromTZDateTime(dt))
          .cast<Month>()
          .map((m) => m.days().length).toList();
      expect(days, [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]);
    });

    test('time ordering for months', (){
      var m1 = Month(2015,6);
      var m2 = Month(2015,2);
      expect(m1.isBefore(m2), false);
      expect(m1.isAfter(m2), true);
    });

    test('compareTo months', (){
      var m1 = Month(2015,6);
      var m2 = Month(2015,2);
      expect(m1.compareTo(m2), 1);
      expect(m1.compareTo(m1), 0);
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
  await initializeTimeZone();
  await testMonth();
}
