library test.week_test;

import 'package:date/src/week.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void tests() {
  group('Week tests:', () {
    var location = getLocation('US/Eastern');
    test('week 1, 2020', () {
      var week1 = Week(2020, 1, location);
      expect(week1.start, TZDateTime(location, 2019, 12, 30));
      expect(week1.end, TZDateTime(location, 2020, 1, 6));
    });
    test('week 4, 2020', () {
      var week4 = Week(2020, 4, location);
      expect(week4.start, TZDateTime(location, 2020, 1, 20));
      expect(week4.end, TZDateTime(location, 2020, 1, 27));
    });
    test('week 53, 2020', () {
      var week53 = Week(2020, 53, location);
      expect(week53.start, TZDateTime(location, 2020, 12, 28));
      expect(week53.end, TZDateTime(location, 2021, 1, 4));
    });
    test('week 1, 2021', () {
      var week1 = Week(2021, 1, location);
      expect(week1.start, TZDateTime(location, 2021, 1, 4));
      expect(week1.end, TZDateTime(location, 2021, 1, 11));
    });

  });
}


void main() async {
  await initializeTimeZones();
  tests();
}