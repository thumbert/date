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
    var location = getLocation('Europe/Istanbul');
    var year = Interval(TZDateTime(location, 2016), TZDateTime(location, 2017));
    var months =
        year.splitLeft((dt) => Month(dt.year, dt.month, location: location));
    expect(months.length, 12);
  });
}

testInterval() {
  var location = getLocation('US/Eastern');

  group('Test Interval:', () {
    test('interval', () {
      Interval i1 = Interval(
          TZDateTime(location, 2015, 1, 1), TZDateTime(location, 2015, 1, 2));
      Interval i2 = Interval(
          TZDateTime(location, 2015, 1, 1), TZDateTime(location, 2015, 1, 2));
      Interval i3 = Interval(
          TZDateTime(location, 2015, 1, 1), TZDateTime(location, 2015, 1, 3));
      expect(i1 == i2, true);
      expect(i1 == i3, false);
    });
    test('create interval ending', () {
      var start = TZDateTime(location, 2015, 1, 1);
      var end = TZDateTime(location, 2015, 1, 2);
      var i1 = Interval(start, end);
      expect(Interval.ending(end, Duration(days: 1)), i1);
    });
    test('interval withStart, interval withEnd', () {
      var start = TZDateTime(location, 2015, 1, 10);
      var end = TZDateTime(location, 2015, 1, 20);
      var i1 = Month(2015,1, location: location);
      expect(i1.withStart(start), Interval(start, TZDateTime(location, 2015,2)));
      expect(i1.withEnd(end), Interval(TZDateTime(location, 2015,1), end));
    });
    test('interval abuts', () {
      Interval i1 = Interval(
          TZDateTime(location, 2015, 1, 1), TZDateTime(location, 2015, 1, 2));
      Interval i2 = Interval(
          TZDateTime(location, 2015, 1, 1), TZDateTime(location, 2015, 1, 2));
      Interval i3 = Interval(
          TZDateTime(location, 2015, 1, 2), TZDateTime(location, 2015, 1, 3));
      expect(i1.abuts(i2), false);
      expect(i1.abuts(i3), true);
      expect(i3.abuts(i1), true);
    });

    test('interval contains time ', () {
      Interval i1 = Interval(
          TZDateTime(location, 2015), TZDateTime(location, 2015, 1, 2));
      expect(i1.containsTime(TZDateTime(location, 2015)), true);
      expect(i1.containsTime(TZDateTime(location, 2015, 1, 2)), false);
      expect(i1.containsTime(TZDateTime(location, 2015, 1, 1, 15)), true);
    });

    test('interval contains another interval', () {
      Interval i1 = Interval(
          TZDateTime(location, 2015), TZDateTime(location, 2015, 1, 2));
      Interval i2 = Interval(
          TZDateTime(location, 2015), TZDateTime(location, 2015, 1, 1, 15));
      Interval i3 = Interval(
          TZDateTime(location, 2014), TZDateTime(location, 2015, 1, 1, 15));
      Interval i4 = Interval(TZDateTime(location, 2015, 1, 1, 10),
          TZDateTime(location, 2015, 1, 2));

      expect(i1.containsInterval(i2), true);
      expect(i1.containsInterval(i1), true);
      expect(i1.containsInterval(i3), false);
      expect(i1.containsInterval(i4), true);
    });

    test('interval overlap', () {
      Interval i1 = Interval(
          TZDateTime(location, 2015, 1, 1), TZDateTime(location, 2015, 1, 2));
      Interval i2 = Interval(TZDateTime(location, 2015, 1, 1, 15),
          TZDateTime(location, 2015, 1, 3));
      expect(i1.overlap(i2), Interval(i2.start, i1.end));

      Interval i3 = Interval(
          TZDateTime(location, 2015, 1, 2), TZDateTime(location, 2015, 1, 3));
      Interval i4 = Interval(TZDateTime(location, 2015, 1, 1, 15),
          TZDateTime(location, 2015, 1, 4));
      expect(i3.overlap(i4), Interval(i3.start, i3.end));
    });

    test('instant (degenerate) interval is allowed', () {
      Interval i =
          Interval(TZDateTime(location, 2015), TZDateTime(location, 2015));
      expect(i.isInstant(), true);
      expect(i.toString(), '2015-01-01 00:00:00.000-0500');
    });

    test('compareTo another interval', () {
      var i1 = Interval(TZDateTime.utc(2015), TZDateTime.utc(2016));
      var i2 = Interval(TZDateTime.utc(2016), TZDateTime.utc(2017));
      var i3 = Interval(TZDateTime.utc(2015), TZDateTime.utc(2017));
      expect(i1.compareTo(i2), -1);
      expect(i2.compareTo(i1), 1);
      expect(i1.compareTo(i1), 0);
      expect(i1.compareTo(i3), -1);
      expect(i3.compareTo(i2), -1);
    });


    test('splitting into hours across hour boundary, returns two hours', () {
      TZDateTime start = TZDateTime(location, 2017, 1, 1);
      TZDateTime end = TZDateTime(location, 2017, 1, 1, 2, 15);
      Interval interval = Interval(start, end);
      List res = interval.splitLeft((x) => Hour.beginning(x));
      expect(res.length, 2);
    });
    test(
        'splitting into hours an interval less than an hour, returns an empty list',
        () {
      TZDateTime start = TZDateTime(location, 2017, 1, 1, 1, 10);
      TZDateTime end = TZDateTime(location, 2017, 1, 1, 1, 15);
      Interval interval = Interval(start, end);
      List res = interval.splitLeft((x) => Hour.beginning(x));
      expect(res.length, 0);
    });
    test('splitting into hours an exact hour, returns the hour', () {
      TZDateTime start = TZDateTime(location, 2017, 1, 1, 0);
      TZDateTime end = TZDateTime(location, 2017, 1, 1, 1);
      Interval interval = Interval(start, end);
      List res = interval.splitLeft((x) => Hour.beginning(x));
      expect(res.length, 1);
    });
    test('split three hours into 36 5-min intervals', () {
      TZDateTime start = TZDateTime(location, 2017, 1, 1, 0);
      TZDateTime end = TZDateTime(location, 2017, 1, 1, 3);
      Interval interval = Interval(start, end);
      Duration min5 = Duration(minutes: 5);
      List res = interval.splitLeft((x) => Interval.beginning(x, min5));
      expect(res.length, 36);
    });
    test('Split 1 month into days using splitLeft', () {
      var interval = Month(2017, 3);
      var days = interval.splitLeft((dt) => Date.fromTZDateTime(dt));
      expect(days.length, 31);
    });
    test('Split 3 months into days using splitLeft', () {
      var interval = Interval(
          TZDateTime(location, 2017, 1, 1), TZDateTime(location, 2017, 4, 1));
      var days = interval.splitLeft(
          (dt) => Date(dt.year, dt.month, dt.day, location: location));
      expect(days.length, 90);
    });
    test('Split one year with TZDateTime into months using splitLeft', () {
      Location location = getLocation('Europe/Istanbul');
      var year =
          Interval(TZDateTime(location, 2016), TZDateTime(location, 2017));
      var months =
          year.splitLeft((dt) => Month(dt.year, dt.month, location: location));
      expect(months.length, 12);
    });

    test('Make contiguous intervals', () {
      var i1 = Interval(TZDateTime(location, 2017, 1, 1),
          TZDateTime(location, 2017, 1, 1, 4));
      var i2 = Interval(TZDateTime(location, 2017, 1, 1, 6),
          TZDateTime(location, 2017, 1, 1, 8));
      var i3 = Hour.beginning(TZDateTime(location, 2017, 1, 1, 9));
      var hours = <Interval>[]
        ..addAll(i1.splitLeft((x) => Hour.beginning(x)))
        ..addAll(i2.splitLeft((x) => Hour.beginning(x)))
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
