library test.elec.interval;

import 'dart:io';
import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:date/src/interval.dart';
import 'package:date/src/hour.dart';
import 'package:date/src/month.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/utils.dart';

soloTest() {
  test('Split one year with TZDateTime into months using splitLeft', () {
    Location location = getLocation('Europe/Istanbul');
    var year = new Interval(
        new TZDateTime(location, 2016), new TZDateTime(location, 2017));
    var months = year
        .splitLeft((dt) => new Month(dt.year, dt.month, location: location));
    expect(months.length, 12);
  });
}

testInterval() {
  Location location = getLocation('US/Eastern');

  group('Test Interval:', () {
    test('interval', () {
      Interval i1 = new Interval(new TZDateTime(location, 2015, 1, 1),
          new TZDateTime(location, 2015, 1, 2));
      Interval i2 = new Interval(new TZDateTime(location, 2015, 1, 1),
          new TZDateTime(location, 2015, 1, 2));
      Interval i3 = new Interval(new TZDateTime(location, 2015, 1, 1),
          new TZDateTime(location, 2015, 1, 3));
      expect(i1 == i2, true);
      expect(i1 == i3, false);
    });
    test('create interval ending', () {
      var start = new TZDateTime(location, 2015, 1, 1);
      var end = new TZDateTime(location, 2015, 1, 2);
      Interval i1 = new Interval(start, end);
      expect(new Interval.ending(end, new Duration(days: 1)), i1);
    });

    test('interval abuts', () {
      Interval i1 = new Interval(new TZDateTime(location, 2015, 1, 1),
          new TZDateTime(location, 2015, 1, 2));
      Interval i2 = new Interval(new TZDateTime(location, 2015, 1, 1),
          new TZDateTime(location, 2015, 1, 2));
      Interval i3 = new Interval(new TZDateTime(location, 2015, 1, 2),
          new TZDateTime(location, 2015, 1, 3));
      expect(i1.abuts(i2), false);
      expect(i1.abuts(i3), true);
      expect(i3.abuts(i1), true);
    });

    test('interval contains time ', () {
      Interval i1 = new Interval(
          new TZDateTime(location, 2015), new TZDateTime(location, 2015, 1, 2));
      expect(i1.containsTime(new TZDateTime(location, 2015)), true);
      expect(i1.containsTime(new TZDateTime(location, 2015, 1, 2)), false);
      expect(i1.containsTime(new TZDateTime(location, 2015, 1, 1, 15)), true);
    });

    test('interval contains another interval', () {
      Interval i1 = new Interval(
          new TZDateTime(location, 2015), new TZDateTime(location, 2015, 1, 2));
      Interval i2 = new Interval(new TZDateTime(location, 2015),
          new TZDateTime(location, 2015, 1, 1, 15));
      Interval i3 = new Interval(new TZDateTime(location, 2014),
          new TZDateTime(location, 2015, 1, 1, 15));
      Interval i4 = new Interval(new TZDateTime(location, 2015, 1, 1, 10),
          new TZDateTime(location, 2015, 1, 2));

      expect(i1.containsInterval(i2), true);
      expect(i1.containsInterval(i1), true);
      expect(i1.containsInterval(i3), false);
      expect(i1.containsInterval(i4), true);
    });

    test('interval overlap', () {
      Interval i1 = new Interval(new TZDateTime(location, 2015, 1, 1),
          new TZDateTime(location, 2015, 1, 2));
      Interval i2 = new Interval(new TZDateTime(location, 2015, 1, 1, 15),
          new TZDateTime(location, 2015, 1, 3));
      expect(i1.overlap(i2), new Interval(i2.start, i1.end));

      Interval i3 = new Interval(new TZDateTime(location, 2015, 1, 2),
          new TZDateTime(location, 2015, 1, 3));
      Interval i4 = new Interval(new TZDateTime(location, 2015, 1, 1, 15),
          new TZDateTime(location, 2015, 1, 4));
      expect(i3.overlap(i4), new Interval(i3.start, i3.end));
    });

    test('instant (degenerate) interval is allowed', () {
      Interval i = new Interval(
          new TZDateTime(location, 2015), new TZDateTime(location, 2015));
      expect(i.isInstant(), true);
      expect(i.toString(), '2015-01-01 00:00:00.000-0500');
    });

    test('splitting into hours across hour boundary, returns two hours', () {
      TZDateTime start = new TZDateTime(location, 2017, 1, 1);
      TZDateTime end = new TZDateTime(location, 2017, 1, 1, 2, 15);
      Interval interval = new Interval(start, end);
      List res = interval.splitLeft((x) => new Hour.beginning(x));
      expect(res.length, 2);
    });
    test(
        'splitting into hours an interval less than an hour, returns an empty list',
        () {
      TZDateTime start = new TZDateTime(location, 2017, 1, 1, 1, 10);
      TZDateTime end = new TZDateTime(location, 2017, 1, 1, 1, 15);
      Interval interval = new Interval(start, end);
      List res = interval.splitLeft((x) => new Hour.beginning(x));
      expect(res.length, 0);
    });
    test('splitting into hours an exact hour, returns the hour', () {
      TZDateTime start = new TZDateTime(location, 2017, 1, 1, 0);
      TZDateTime end = new TZDateTime(location, 2017, 1, 1, 1);
      Interval interval = new Interval(start, end);
      List res = interval.splitLeft((x) => new Hour.beginning(x));
      expect(res.length, 1);
    });
    test('split three hours into 36 5-min intervals', () {
      TZDateTime start = new TZDateTime(location, 2017, 1, 1, 0);
      TZDateTime end = new TZDateTime(location, 2017, 1, 1, 3);
      Interval interval = new Interval(start, end);
      Duration min5 = new Duration(minutes: 5);
      List res = interval.splitLeft((x) => new Interval.beginning(x, min5));
      expect(res.length, 36);
    });
    test('Split 1 month into days using splitLeft', () {
      var interval = new Month(2017, 3);
      var days = interval.splitLeft((dt) => new Date.fromTZDateTime(dt));
      expect(days.length, 31);
    });
    test('Split 3 months into days using splitLeft', () {
      var interval = new Interval(new TZDateTime(location, 2017, 1, 1),
          new TZDateTime(location, 2017, 4, 1));
      var days = interval.splitLeft(
          (dt) => new Date(dt.year, dt.month, dt.day, location: location));
      expect(days.length, 90);
    });
    test('Split one year with TZDateTime into months using splitLeft', () {
      Location location = getLocation('Europe/Istanbul');
      var year = new Interval(
          new TZDateTime(location, 2016), new TZDateTime(location, 2017));
      var months = year
          .splitLeft((dt) => new Month(dt.year, dt.month, location: location));
      expect(months.length, 12);
    });

    test('Make contiguous intervals', () {
      var i1 = new Interval(new TZDateTime(location, 2017, 1, 1),
          new TZDateTime(location, 2017, 1, 1, 4));
      var i2 = new Interval(new TZDateTime(location, 2017, 1, 1, 6),
          new TZDateTime(location, 2017, 1, 1, 8));
      var i3 = new Hour.beginning(new TZDateTime(location, 2017, 1, 1, 9));
      var hours = <Interval>[]
        ..addAll(i1.splitLeft((x) => new Hour.beginning(x)))
        ..addAll(i2.splitLeft((x) => new Hour.beginning(x)))
        ..add(i3);
      var res = makeContiguousIntervals(hours);
      expect(res, [i1, i2, i3]);
      expect(makeContiguousIntervals([i3]), [i3]);
    });
  });
}

main() async {
  Map env = Platform.environment;
  String tzdb = env['HOME'] +
      '/.pub-cache/hosted/pub.dartlang.org/timezone-0.4.3/lib/data/2015b.tzf';
  await initializeTimeZone(tzdb);

  // soloTest();
  await testInterval();
}
