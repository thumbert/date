library test.hour_test;

import 'dart:io';
import 'package:test/test.dart';
import 'package:date/src/hour.dart';
import 'package:date/src/time_iterable.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/src/env.dart';

hour_test() {
  Location location = getLocation('US/Eastern');  // 'US/Mountain', 'US/Central', 'US/Pacific'
  group('Test Hour: ', () {
    test('create hour', (){
      Hour h = new Hour.beginning(new TZDateTime(location, 2015, 1, 1));
      expect(h.end, new TZDateTime(location, 2015, 1, 1, 1));
      expect(h.toString(), '[2015-01-01 00:00:00.000-0500, 2015-01-01 01:00:00.000-0500)');
    });

    test('next/previous hour', () {
      Hour h = new Hour.beginning(new TZDateTime(location, 2015, 1, 1));
      expect(h.next, new Hour.beginning(new TZDateTime(location, 2015, 1, 1, 1)));
      expect(h.previous, new Hour.ending(new TZDateTime(location, 2015, 1, 1)));
    });

    test('hour iterable around DST', () {
      TimeIterable it1 = new TimeIterable(
          new Hour.beginning(new TZDateTime(location, 2015, 3, 8, 0)),
          new Hour.beginning(new TZDateTime(location, 2015, 3, 8, 5)));
      //it1.forEach((h) => print(h));
      expect(it1.length, 5);  // spring forward

      TimeIterable it2 = new TimeIterable(
          new Hour.beginning(new TZDateTime(location, 2015, 11, 1, 0)),
          new Hour.beginning(new TZDateTime(location, 2015, 11, 1, 5)));
      //it2.forEach((h) => print(h));
      expect(it2.length, 7);  // fall back
    });

    test('get all the hours in year 2016 (leap year)', () {
      Hour start = new Hour.beginning(new TZDateTime(location, 2016));
      Hour end = new Hour.ending(new TZDateTime(location, 2017));
      List hours = new TimeIterable(start, end).toList();
      expect(hours.length, 8784);
    });

  });
}


main() async {
  Map env = Platform.environment;
  String tzdb = env['HOME'] + '/.pub-cache/hosted/pub.dartlang.org/timezone-0.4.3/lib/data/2015b_all.tzf';
  initializeTimeZoneSync(tzdb);

  hour_test();
}

