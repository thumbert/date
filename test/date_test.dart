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
    test('From year month day to Julian day', () {
      expect(Date(1970, 1, 1).value, 0);
      expect(Date(2014, 1, 1).value, 16071);
      expect(Date(1900, 1, 1).value, -25567);
      expect(Date(2100, 1, 1).value, 47482);
    });

    test('Constructor from TZDateTime for DST', (){
      var eastern = getLocation('US/Eastern');
      var dst = Date.fromTZDateTime(TZDateTime(eastern,2017,3,12));
      expect(dst.end, TZDateTime(eastern,2017,3,13));
    });

    test('Parse a string', (){
      expect(Date.parse('20150101'), Date(2015,1,1));
      expect(Date.parse('2015-01-03'), Date(2015,1,3));
      expect(Date.parse('2015-0103'), Date(2015,1,3));
      expect(Date.parse('20150229'), Date(2015,3,1));  // !!! same as DateTime
    });

    test('Parse a string with specific format', (){
      expect(Date.parse('29May20', fmt: DateFormat('ddMMMyy')), Date(2020,5,29));
    });

    test('From Julian day to year month day', () {
      var d = Date(2014, 5, 15);
      expect([d.year, d.month, d.day], [2014, 5, 15]);
      var d2 = Date.fromJulianDay(d.value);
      expect([d2.year, d2.month, d2.day], [2014, 5, 15]);
      expect(d2.value, 16205);
    });

    test('From Excel date', () {
      expect(Date.fromExcel(25569), Date(1970,1,1));
      expect(Date.fromExcel(43987), Date(2020,6,5));
      expect(Date.fromExcel(18264), Date(1950,1,1));
      expect(Date.fromExcel(3654), Date(1910,1,1));
      expect(Date.fromExcel(367), Date(1901,1,1));
    });

    test('Day of week (Mon=1, ... Sat=6, Sun=7)', () {
      expect(Date(2014, 12, 19).weekday, 5);
      expect(Date(2014, 1, 1).weekday, 3);
      expect(Date(2014, 2, 1).weekday, 6);
      expect(Date(2014, 3, 3).weekday, 1);
      expect(Date(2014, 4, 15).weekday, 2);
      expect(Date(2014, 6, 15).weekday, 7);
      expect(Date(2014, 8, 14).weekday, 4);
    });

    test('Day of the year', () {
      expect(Date(2015, 1, 1).dayOfYear(), 1);
      expect(Date(2015, 12, 31).dayOfYear(), 365);
      expect(Date(2000, 12, 31).dayOfYear(), 366);
      expect(Date(2004, 12, 31).dayOfYear(), 366);
    });

    test('Is weekend', () {
      expect(Date(2018, 4, 14).isWeekend(), true);
      expect(Date(2018, 4, 15).isWeekend(), true);
      expect(Date(2018, 4, 16).isWeekend(), false);
    });


    test('next/previous day', (){
      expect(Date(2015, 2, 28).next, Date(2015,3,1));
      expect(Date(2015, 1, 1).previous, Date(2014,12,31));
    });

    test('current/next/previous month', (){
      expect(Date(2015,2,28).beginningOfMonth, Date(2015,2,1));
      expect(Date(2015,2,28).currentMonth().next.startDate, Date(2015,3,1));
      expect(Date(2015,2,28).currentMonth().previous.startDate, Date(2015,1,1));
    });

    test('nextN/previousN days', (){
      var date = Date(2015, 2, 3);
      expect(date.nextN(3), [date.add(1), date.add(2), date.add(3)]);
      expect(date.previousN(3), [date.subtract(3), date.subtract(2), date.subtract(1)]);
    });


    test('add/subtract days', () {
      expect(Date(2015,1,1).add(1), Date(2015,1,2));
      expect(Date(2015,1,1).subtract(1), Date(2014,12,31));
      expect(Date(2015,1,1).add(-1), Date(2014,12,31));
    });

    test('Change the date display format', () {
      var fmt = DateFormat('dMMMyy');
      expect(Date(2014, 1, 1).toString(fmt), '1Jan14');
    });

    test('Sort dates', (){
      var x = [Date(2014,8,1), Date(2014,12,1), Date(2014,2,1)];
      x.sort();
      expect(x.map((d) => d.toString()).join(','),
      '2014-02-01,2014-08-01,2014-12-01');
    });

    test('toSet() on a list of Dates', () {
      var x = [Date(2014,1,1), Date(2014,1,1)];
      expect(x.toSet().toList().length, 1);
    });

    test('start/end of a Date', () {
      var x = Date(2016,1,1);
      expect(x.start.toString(), '2016-01-01 00:00:00.000Z');
      expect(x.end.toString(), '2016-01-02 00:00:00.000Z');
    });

    test('start/end of a Date after you add one day', () {
      var x = Date(2016,1,1);
      var y = x.add(1);
      expect(y.start.toString(), '2016-01-02 00:00:00.000Z');
      expect(y.end.toString(), '2016-01-03 00:00:00.000Z');
    });

    test('compare Dates', (){
      var x = Date(2016, 1, 1);
      var y = Date(2017, 3, 3);
      expect(x.compareTo(y), -1);
    });

    test('get hours in day', (){
      var hours = Date(2019, 1, 1).hours();
      expect(hours.length, 24);
      expect(hours.first, Hour.beginning(TZDateTime.utc(2019)));
    });

  });
}




void main() async {
  await initializeTimeZone();
  await testDate();
//  await testDateIterable();
}
