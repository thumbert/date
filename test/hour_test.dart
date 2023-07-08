library test.hour_test;

import 'package:date/date.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';

void tests() {
  var location = getLocation(
      'America/New_York'); // 'US/Mountain', 'US/Central', 'US/Pacific'
  group('Test Hour:', () {
    test('create hour', () {
      var h = Hour.beginning(TZDateTime(location, 2015, 1, 1));
      expect(h.end, TZDateTime(location, 2015, 1, 1, 1));
      expect(h.toString(),
          '[2015-01-01 00:00:00.000-0500, 2015-01-01 01:00:00.000-0500)');
    });

    test('next/previous hour', () {
      var h = Hour.beginning(TZDateTime(location, 2015, 1, 1));
      expect(h.next, Hour.beginning(TZDateTime(location, 2015, 1, 1, 1)));
      expect(h.previous, Hour.ending(TZDateTime(location, 2015, 1, 1)));
    });

    test('hour iterable around DST', () {
      var it1 = Interval(TZDateTime(location, 2015, 3, 8, 0),
          TZDateTime(location, 2015, 3, 8, 6));
      expect(it1.splitLeft((dt) => Hour.beginning(dt)).length,
          5); // spring forward

      var it2 = Interval(TZDateTime(location, 2015, 11, 1, 0),
          TZDateTime(location, 2015, 11, 1, 6));
      expect(it2.splitLeft((dt) => Hour.beginning(dt)).length, 7); // fall back
    });

    test('split an year into hours', () {
      var year =
          Interval(TZDateTime(location, 2016), TZDateTime(location, 2017));
      var hours = year.splitLeft((dt) => Hour.beginning(dt));
      expect(hours.length, 8784);
    });

    test('isBeginningOfHour', () {
      var dt1 = TZDateTime(location, 2018, 1, 1, 6);
      expect(isBeginningOfHour(dt1), true);
      expect(isBeginningOfHour(TZDateTime(location, 2018, 1, 1, 6, 1)), false);
    });
  });
}

/// As of 7/7/2023:
/// With UTC DateTime: 20 ms
/// With local DateTime: 26 ms
/// With TZDateTime: 62 ms
/// With Hour: 81 ms
/// Rust with chrono_tz: 16 ms
///
void speedTest() {
  var location = getLocation('America/New_York');
  const H1 = const Duration(hours: 1);
  var sw = Stopwatch()..start();
  var dt = DateTime.utc(2000);
  for (var i = 0; i < 201624; i++) {
    dt = dt.add(H1);
  }
  sw.stop();
  print('With UTC DateTime: ${sw.elapsedMilliseconds} ms');

  sw.start();
  dt = DateTime(2000);
  for (var i = 0; i < 201624; i++) {
    dt = dt.add(H1);
  }
  sw.stop();
  print('With local DateTime: ${sw.elapsedMilliseconds} ms');

  sw.start();
  dt = TZDateTime(location, 2000);
  for (var i = 0; i < 201624; i++) {
    dt = dt.add(H1);
  }
  sw.stop();
  print('With TZDateTime: ${sw.elapsedMilliseconds} ms');

  sw.start();
  var hour = Hour.beginning(TZDateTime(location, 2000));
  for (var i = 0; i < 201624; i++) {
    hour = hour.next;
  }
  sw.stop();
  print('With Hour: ${sw.elapsedMilliseconds} ms');
}

main() {
  initializeTimeZones();
  // tests();
  speedTest();
}
