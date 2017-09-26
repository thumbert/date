
library test.elec.interval;

import 'dart:io';
import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:date/src/interval.dart';

main() {
  Map env = Platform.environment;
  String tzdb = env['HOME'] +
      '/.pub-cache/hosted/pub.dartlang.org/timezone-0.4.3/lib/data/2015b.tzf';
  initializeTimeZoneSync(tzdb);
  Location location = getLocation('US/Eastern');
  
  test('interval', () {
    Interval i1 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i2 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i3 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,3));
    //print(i1.toString());
    expect(i1 == i2, true);
    expect(i1 == i3, false);
  });

  test('interval abuts', () {
    Interval i1 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i2 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i3 = new Interval(new DateTime(2015,1,2), new DateTime(2015,1,3));
    expect(i1.abuts(i2), false);
    expect(i1.abuts(i3), true);
    expect(i3.abuts(i1), true);
  });

  test('interval overlap', () {
    Interval i1 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i2 = new Interval(new DateTime(2015,1,1,15), new DateTime(2015,1,3));
    expect(i1.overlap(i2), new Interval(i2.start, i1.end));

    Interval i3 = new Interval(new DateTime(2015,1,2), new DateTime(2015,1,3));
    Interval i4 = new Interval(new DateTime(2015,1,1,15), new DateTime(2015,1,4));
    expect(i3.overlap(i4), new Interval(i3.start, i3.end));
  });

  test('interval hashCode', () {
    Interval i1 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    //print(i1.hashCode);
  });

  test('instant (degenerate) interval', () {
    Interval i = new Interval(new DateTime(2015), new DateTime(2015));
    expect(i.isInstant(), true);
    //print(i.toString());
    expect(i.toString(), '2015-01-01 00:00:00.000');
  });

  
  test('splitting into hours across hour boundary, returns two hours', () {
    TZDateTime start = new TZDateTime(location, 2017,1,1);
    TZDateTime end = new TZDateTime(location, 2017,1,1,1,15);
    Interval interval = new Interval(start, end);
    List res = splitIntoHours(interval);
    expect(res.length, 2);
  });
  test('splitting into hours an interval less than an hour, returns an empty list', () {
    TZDateTime start = new TZDateTime(location, 2017,1,1,1,10);
    TZDateTime end = new TZDateTime(location,   2017,1,1,1,15);
    Interval interval = new Interval(start, end);
    List res = splitIntoHours(interval);
    expect(res.length, 0);
  });
  test('splitting into hours an exact hour, returns the hour', () {
    TZDateTime start = new TZDateTime(location, 2017,1,1,0);
    TZDateTime end = new TZDateTime(location,   2017,1,1,1);
    Interval interval = new Interval(start, end);
    List res = splitIntoHours(interval);
    expect(res.length, 1);
  });
  
  test('Make contiguous intervals', () {
    var i1 = new Interval(new TZDateTime(location, 2017, 1, 1),
        new TZDateTime(location, 2017, 1, 1, 4));
    var i2 = new Interval(new TZDateTime(location, 2017, 1, 1, 6),
        new TZDateTime(location, 2017, 1, 1, 8));
    var i3 = new Hour.beginning(new TZDateTime(location, 2017, 1, 1, 9));
    List hours = []
      ..addAll(splitIntoHours(i1))
      ..addAll(splitIntoHours(i2))
      ..add(i3);
    var res = makeContiguousIntervals(hours);
    expect(res, [i1, i2, i3]);
    //res.forEach(print);
    expect(makeContiguousIntervals([i3]), [i3]);
  });
  
}
