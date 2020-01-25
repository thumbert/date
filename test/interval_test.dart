library test.elec.interval;

import 'package:date/date.dart';
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
      var i1 = Month(2015, 1, location: location);
      expect(
          i1.withStart(start), Interval(start, TZDateTime(location, 2015, 2)));
      expect(i1.withEnd(end), Interval(TZDateTime(location, 2015, 1), end));
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
      expect(i1.overlap(i2), i2.overlap(i1));

      Interval i3 = Interval(
          TZDateTime(location, 2015, 1, 2), TZDateTime(location, 2015, 1, 3));
      Interval i4 = Interval(TZDateTime(location, 2015, 1, 1, 15),
          TZDateTime(location, 2015, 1, 4));
      expect(i3.overlap(i4), Interval(i3.start, i3.end));
      expect(i3.overlap(i4), i4.overlap(i3));
    });
    test('interval overlap, no overlap returns null', () {
      var i1 = parseTerm('1Jan19-5Jan19');
      var i2 = parseTerm('15Jan19-25Jan19');
      expect(i1.overlap(i2), null);
    });

    test('instant (degenerate) interval is allowed', () {
      Interval i =
          Interval(TZDateTime(location, 2015), TZDateTime(location, 2015));
      expect(i.isInstant(), true);
      expect(i.toString(), '2015-01-01 00:00:00.000-0500');
    });

    test('calculate the covering of several intervals', () {
      var i1 = Interval(
          TZDateTime(location, 2015, 1, 1), TZDateTime(location, 2015, 1, 2));
      var i2 = Interval(TZDateTime(location, 2015, 1, 1, 15),
          TZDateTime(location, 2015, 1, 3));
      var i3 = Interval(
          TZDateTime(location, 2015, 1, 2), TZDateTime(location, 2015, 1, 3));
      var i4 = Interval(TZDateTime(location, 2015, 1, 1, 15),
          TZDateTime(location, 2015, 1, 4));
      expect(Interval.covering([i1, i2, i3, i4]), Interval(i1.start, i4.end));
    });

    test('fuse intervals, 1', () {
      var d1 = Date(2019,1,1);
      var d2 = Date(2019,1,2);
      var d3 = Date(2019,1,3);
      var d4 = Date(2019,1,7);
      var d5 = Date(2019,1,8);
      var res = Interval.fuse([d1, d2, d3, d4, d5]);
      expect(res, [
        parseTerm('1Jan19-3Jan19'),
        parseTerm('7Jan19-8Jan19'),
      ]);
    });

    test('fuse intervals, 2', () {
      var d1 = Date(2019,1,1);
      var d2 = Date(2019,1,2);
      var d3 = Date(2019,1,3);
      var d4 = Date(2019,1,4);
      var d5 = Date(2019,1,8);
      var res = Interval.fuse([d1, d2, d3, d4, d5]);
      expect(res, [
        parseTerm('1Jan19-4Jan19'),
        Date(2019,1,8),
      ]);
    });


    test('difference 1 interval, middle overlap', () {
      var one = parseTerm('1Jan19-5Jan19');
      expect(one.difference([parseTerm('2Jan19-3Jan19')]), [
        Interval(TZDateTime.utc(2019), TZDateTime.utc(2019, 1, 2)),
        parseTerm('4Jan19-5Jan19')
      ]);
    });
    test('difference 1 interval, all overlap', () {
      var one = parseTerm('1Jan19-5Jan19');
      expect(one.difference([parseTerm('3Mar19-10Mar19')]), [one]);
    });
    test('difference 1 interval, left overlap', () {
      var one = parseTerm('1Jan19-5Jan19');
      expect(one.difference([parseTerm('3Jan19-18Jan19')]), [
        Interval(TZDateTime.utc(2019), TZDateTime.utc(2019, 1, 3)),
      ]);
    });
    test('difference 1 interval, right overlap', () {
      var one = parseTerm('1Jan19-5Jan19');
      expect(one.difference([parseTerm('24Dec18-3Jan19')]), [
        Interval(TZDateTime.utc(2019, 1, 4), TZDateTime.utc(2019, 1, 6)),
      ]);
    });
    test('difference 1 interval, no difference', () {
      var one = parseTerm('1Jan19-5Jan19');
      expect(one.difference([parseTerm('24Dec18-13Jan19')]), []);
    });
    test('difference multiple intervals', () {
      var one = parseTerm('1Jan19-5Jan19');
      var two = parseTerm('8Jan19-11Jan19');
      var three = parseTerm('14Jan19-18Jan19');
      var four = parseTerm('20Jan19-22Jan19');
      var interval = parseTerm('3Jan19-15Jan19');
      var res = interval.difference([one, two, three, four]);
      expect(res, [
        parseTerm('6Jan19-7Jan19'),
        parseTerm('12Jan19-13Jan19'),
      ]);
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
      var start = TZDateTime(location, 2017, 1, 1);
      var end = TZDateTime(location, 2017, 1, 1, 2, 15);
      var interval = Interval(start, end);
      var res = interval.splitLeft((x) => Hour.beginning(x));
      expect(res.length, 2);
      expect(res.first is Hour, true);
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
  await initializeTimeZone();
  await testInterval();
}
