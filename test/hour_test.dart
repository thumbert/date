library test.hour_test;

import 'dart:io';
import 'package:test/test.dart';
import 'package:date/src/hour.dart';
import 'package:date/src/interval.dart';
import 'package:date/src/time_iterable.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/src/env.dart';

hourTest() {
  Location location = getLocation('US/Eastern');  // 'US/Mountain', 'US/Central', 'US/Pacific'
  group('Test Hour:', () {
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
      var it1 = Interval(TZDateTime(location, 2015, 3, 8, 0),
          TZDateTime(location, 2015, 3, 8, 6));
      expect(it1.splitLeft((dt) => Hour.beginning(dt)).length, 5);  // spring forward

      var it2 = Interval(TZDateTime(location, 2015, 11, 1, 0),
          TZDateTime(location, 2015, 11, 1, 6));
      expect(it2.splitLeft((dt) => Hour.beginning(dt)).length, 7);  // fall back
    });

    test('split an year into hours', () {
      var year = Interval(TZDateTime(location, 2016),
          TZDateTime(location, 2017));
      var hours = year.splitLeft((dt) => Hour.beginning(dt));
      expect(hours.length, 8784);
    });

  });
}


main() async {
  Map env = Platform.environment;
  String tzdb = env['HOME'] + '/.pub-cache/hosted/pub.dartlang.org/timezone-0.4.3/lib/data/2015b_all.tzf';
  await initializeTimeZone(tzdb);

  await hourTest();
}

