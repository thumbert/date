// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library test.date;

import 'package:test/test.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/standalone.dart';
import 'package:date/date.dart';

void testDate() {
  group('Test Date:', () {
    test('Date.utc constructor', () {
      var date = Date.utc(2019, 10, 1);
      expect(date.start, TZDateTime.utc(2019, 10, 1));
      expect(date.end, TZDateTime.utc(2019, 10, 2));
    });

    test('From year month day to Julian day', () {
      expect(Date(1970, 1, 1, location: UTC).value, 0);
      expect(Date(2014, 1, 1, location: UTC).value, 16071);
      expect(Date(1900, 1, 1, location: UTC).value, -25567);
      expect(Date(2100, 1, 1, location: UTC).value, 47482);
    });

    test('Constructor from TZDateTime for DST', () {
      var eastern = getLocation('America/New_York');
      var dst = Date.containing(TZDateTime(eastern, 2017, 3, 12));
      expect(dst.end, TZDateTime(eastern, 2017, 3, 13));
    });

    test('Parse a string', () {
      expect(Date.parse('20150101'), Date(2015, 1, 1, location: UTC));
      expect(Date.parse('2015-01-03'), Date(2015, 1, 3, location: UTC));
      expect(Date.parse('2015-0103'), Date(2015, 1, 3, location: UTC));
      // Note that 2015-02-29 does not exist
      expect(Date.parse('20150229'),
          Date(2015, 3, 1, location: UTC)); // !!! same as DateTime
      expect(Date.parse('2/22/2015'), Date(2015, 2, 22, location: UTC));
      expect(Date.parse('22Feb15'), Date(2015, 2, 22, location: UTC));
    });

    test('Parse a string with specific format', () {
      expect(
          Date.parse('29May20'), //fmt: DateFormat('ddMMMyy')),
          Date(2020, 5, 29, location: UTC));
    });

    test('From Julian day to year month day', () {
      var d = Date(2014, 5, 15, location: UTC);
      expect([d.year, d.month, d.day], [2014, 5, 15]);
      var d2 = Date.fromJulianDay(d.value);
      expect([d2.year, d2.month, d2.day], [2014, 5, 15]);
      expect(d2.value, 16205);
    });

    test('From Excel date', () {
      expect(Date.fromExcel(25569), Date(1970, 1, 1, location: UTC));
      expect(Date.fromExcel(43987), Date(2020, 6, 5, location: UTC));
      expect(Date.fromExcel(18264), Date(1950, 1, 1, location: UTC));
      expect(Date.fromExcel(3654), Date(1910, 1, 1, location: UTC));
      expect(Date.fromExcel(367), Date(1901, 1, 1, location: UTC));
    });

    test('From integer', () {
      expect(Date.fromInt(20220517), Date.utc(2022, 5, 17));
      expect(Date.fromInt(20220517, location: local),
          Date(2022, 5, 17, location: UTC));
    });

    test('to Excel date', () {
      expect(25569, Date(1970, 1, 1, location: UTC).toExcel());
      expect(43987, Date(2020, 6, 5, location: UTC).toExcel());
      expect(18264, Date(1950, 1, 1, location: UTC).toExcel());
      expect(3654, Date(1910, 1, 1, location: UTC).toExcel());
      expect(367, Date(1901, 1, 1, location: UTC).toExcel());
      // expect(1, Date(1900, 1, 1).toExcel());  // FAILS -- not sure why!
    });

    test('to integer', () {
      expect(20240415, Date(2024, 4, 15, location: UTC).toInt());
    });

    test('Day of week (Mon=1, ... Sat=6, Sun=7)', () {
      expect(Date(2014, 12, 19, location: UTC).weekday, 5);
      expect(Date(2014, 1, 1, location: UTC).weekday, 3);
      expect(Date(2014, 2, 1, location: UTC).weekday, 6);
      expect(Date(2014, 3, 3, location: UTC).weekday, 1);
      expect(Date(2014, 4, 15, location: UTC).weekday, 2);
      expect(Date(2014, 6, 15, location: UTC).weekday, 7);
      expect(Date(2014, 8, 14, location: UTC).weekday, 4);
    });

    test('Day of the year', () {
      expect(Date(2015, 1, 1, location: UTC).dayOfYear(), 1);
      expect(Date(2015, 12, 31, location: UTC).dayOfYear(), 365);
      expect(Date(2000, 12, 31, location: UTC).dayOfYear(), 366);
      expect(Date(2004, 12, 31, location: UTC).dayOfYear(), 366);
    });

    test('Is weekend', () {
      expect(Date(2018, 4, 14, location: UTC).isWeekend(), true);
      expect(Date(2018, 4, 15, location: UTC).isWeekend(), true);
      expect(Date(2018, 4, 16, location: UTC).isWeekend(), false);
    });

    test('next/previous day', () {
      expect(Date(2015, 2, 28, location: UTC).next,
          Date(2015, 3, 1, location: UTC));
      expect(Date(2015, 1, 1, location: UTC).previous,
          Date(2014, 12, 31, location: UTC));
    });

    test('current/next/previous month', () {
      expect(Date(2015, 2, 28, location: UTC).beginningOfMonth,
          Date(2015, 2, 1, location: UTC));
      expect(Date(2015, 2, 28, location: UTC).currentMonth().next.startDate,
          Date(2015, 3, 1, location: UTC));
      expect(Date(2015, 2, 28, location: UTC).currentMonth().previous.startDate,
          Date(2015, 1, 1, location: UTC));
    });

    test('nextN/previousN days', () {
      var date = Date(2015, 2, 3, location: UTC);
      expect(date.nextN(3), [date.add(1), date.add(2), date.add(3)]);
      expect(date.previousN(3),
          [date.subtract(3), date.subtract(2), date.subtract(1)]);
    });

    test('add/subtract days', () {
      expect(Date(2015, 1, 1, location: UTC).add(1),
          Date(2015, 1, 2, location: UTC));
      expect(Date(2015, 1, 1, location: UTC).subtract(1),
          Date(2014, 12, 31, location: UTC));
      expect(Date(2015, 1, 1, location: UTC).add(-1),
          Date(2014, 12, 31, location: UTC));
    });

    test('Change the date display format', () {
      var fmt = DateFormat('dMMMyy');
      expect(Date(2014, 1, 1, location: UTC).toString(fmt), '1Jan14');
    });

    test('Sort dates', () {
      var x = [
        Date(2014, 8, 1, location: UTC),
        Date(2014, 12, 1, location: UTC),
        Date(2014, 2, 1, location: UTC)
      ];
      x.sort();
      expect(x.map((d) => d.toString()).join(','),
          '2014-02-01,2014-08-01,2014-12-01');
    });

    test('toSet() on a list of Dates', () {
      var x = [
        Date(2014, 1, 1, location: UTC),
        Date(2014, 1, 1, location: UTC)
      ];
      expect(x.toSet().toList().length, 1);
    });

    test('start/end of a Date', () {
      var x = Date(2016, 1, 1, location: UTC);
      expect(x.start.toString(), '2016-01-01 00:00:00.000Z');
      expect(x.end.toString(), '2016-01-02 00:00:00.000Z');
    });

    test('start/end of a Date after you add one day', () {
      var x = Date(2016, 1, 1, location: UTC);
      var y = x.add(1);
      expect(y.start.toString(), '2016-01-02 00:00:00.000Z');
      expect(y.end.toString(), '2016-01-03 00:00:00.000Z');
    });

    test('compare Dates', () {
      var x = Date(2016, 1, 1, location: UTC);
      var y = Date(2017, 3, 3, location: UTC);
      expect(x.compareTo(y), -1);
    });

    test('get hours in day', () {
      var hours = Date(2019, 1, 1, location: UTC).hours();
      expect(hours.length, 24);
      expect(hours.first, Hour.beginning(TZDateTime.utc(2019)));
    });

    test('number of hours in a day', () {
      final location = getLocation('America/New_York');
      expect(Date(2024, 3, 12, location: location).hoursInDay, 24);
      expect(Date(2024, 3, 10, location: location).hoursInDay, 23);
      expect(Date(2024, 11, 3, location: location).hoursInDay, 25);
    });
  });
}

void main() async {
  await initializeTimeZone();
  testDate();
//  await testDateIterable();
}
