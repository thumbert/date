library test.hour_test;

import 'dart:io';
import 'package:date/date.dart';
import 'package:test/test.dart';
import 'package:date/src/hour.dart';
import 'package:date/src/interval.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/src/env.dart';

hourTest() {
  Location location = getLocation('America/New_York');  // 'US/Mountain', 'US/Central', 'US/Pacific'
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

    test('isBeginningOfHour', (){
      var dt1 = TZDateTime(location, 2018, 1, 1, 6);
      expect(isBeginningOfHour(dt1), true);
      expect(isBeginningOfHour(TZDateTime(location, 2018, 1, 1, 6, 1)), false);

    });

  });
}


main() async {
  await initializeTimeZone();
  await hourTest();
}

