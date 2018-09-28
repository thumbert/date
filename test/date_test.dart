// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library test.date;

import 'dart:io';
import 'package:test/test.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/standalone.dart';
import 'package:date/date.dart';
import 'package:date/src/time_iterable.dart';
import 'package:date/src/month.dart';


testDate() {
  group("Test Date:", () {
    test("From year month day to Julian day", () {
      expect(new Date(1970, 1, 1).value, 0);
      expect(new Date(2014, 1, 1).value, 16071);
      expect(new Date(1900, 1, 1).value, -25567);
      expect(new Date(2100, 1, 1).value, 47482);
    });

    test('Constructor from TZDateTime for DST', (){
      Location eastern = getLocation('US/Eastern');
      var dst = new Date.fromTZDateTime(new TZDateTime(eastern,2017,3,12));
      expect(dst.end, new TZDateTime(eastern,2017,3,13));
    });

    test('Parse a string', (){
      expect(Date.parse('20150101'), new Date(2015,1,1));
      expect(Date.parse('2015-01-03'), new Date(2015,1,3));
      expect(Date.parse('2015-0103'), new Date(2015,1,3));
      expect(Date.parse('20150229'), new Date(2015,3,1));  // !!! same as DateTime
    });

    test("From Julian day to year month day", () {
      Date d = new Date(2014, 5, 15);
      expect([d.year, d.month, d.day], [2014, 5, 15]);
      Date d2 = Date.fromJulianDay(d.value);
      expect([d2.year, d2.month, d2.day], [2014, 5, 15]);
      expect(d2.value, 16205);
    });

    test("Day of week (Mon=1, ... Sat=6, Sun=7)", () {
      expect(new Date(2014, 12, 19).weekday, 5);
      expect(new Date(2014, 1, 1).weekday, 3);
      expect(new Date(2014, 2, 1).weekday, 6);
      expect(new Date(2014, 3, 3).weekday, 1);
      expect(new Date(2014, 4, 15).weekday, 2);
      expect(new Date(2014, 6, 15).weekday, 7);
      expect(new Date(2014, 8, 14).weekday, 4);
    });

    test("Day of the year", () {
      expect(new Date(2015, 1, 1).dayOfYear(), 1);
      expect(new Date(2015, 12, 31).dayOfYear(), 365);
      expect(new Date(2000, 12, 31).dayOfYear(), 366);
      expect(new Date(2004, 12, 31).dayOfYear(), 366);
    });

    test("Is weekend", () {
      expect(new Date(2018, 4, 14).isWeekend(), true);
      expect(new Date(2018, 4, 15).isWeekend(), true);
      expect(new Date(2018, 4, 16).isWeekend(), false);
    });


    test('next/previous day', (){
      expect(new Date(2015, 2, 28).next, new Date(2015,3,1));
      expect(new Date(2015, 1, 1).previous, new Date(2014,12,31));
    });

    test('current/next/previous month', (){
      expect(new Date(2015,2,28).beginningOfMonth, new Date(2015,2,1));
      expect(new Date(2015,2,28).currentMonth().next.startDate, new Date(2015,3,1));
      expect(new Date(2015,2,28).currentMonth().previous.startDate, new Date(2015,1,1));
    });

    test('nextN/previousN days', (){
      var date = new Date(2015, 2, 3);
      expect(date.nextN(3), [date.add(1), date.add(2), date.add(3)]);
      expect(date.previousN(3), [date.subtract(3), date.subtract(2), date.subtract(1)]);
    });


    test('add/subtract days', () {
      expect(new Date(2015,1,1).add(1), new Date(2015,1,2));
      expect(new Date(2015,1,1).subtract(1), new Date(2014,12,31));
      expect(new Date(2015,1,1).add(-1), new Date(2014,12,31));
    });

    test("Change the date display format", () {
      var fmt = new DateFormat("dMMMyy");
      expect(new Date(2014, 1, 1).toString(fmt), "1Jan14");
    });

    test("Sort dates", (){
      var x = [new Date(2014,8,1), new Date(2014,12,1),
      new Date(2014,2,1)];
      x.sort();
      expect(x.map((d) => d.toString()).join(","),
      "2014-02-01,2014-08-01,2014-12-01");
    });

    test("toSet() on a list of Dates", () {
      var x = [new Date(2014,1,1), new Date(2014,1,1)];
      expect(x.toSet().toList().length, 1);
    });

    test('start/end of a Date', () {
      var x = new Date(2016,1,1);
      expect(x.start.toString(), '2016-01-01 00:00:00.000Z');
      expect(x.end.toString(), '2016-01-02 00:00:00.000Z');
    });

    test('start/end of a Date after you add one day', () {
      var x = new Date(2016,1,1);
      var y = x.add(1);
      expect(y.start.toString(), '2016-01-02 00:00:00.000Z');
      expect(y.end.toString(), '2016-01-03 00:00:00.000Z');
    });

    test('compare Dates', (){
      var x = new Date(2016, 1, 1);
      var y = new Date(2017, 3, 3);
      expect(x.compareTo(y), -1);
    });

  });
}

testDateIterable() {
  group('Test TimeIterable: ', () {
    test('daily for 5 days', () {
      TimeIterable<Date> range = new TimeIterable(new Date(2015,1,1), new Date(2015,1,5));
      expect(range.length, 5);
      expect(range.last, new Date(2015,1,5));
    });

    test('daily iterable start/end gets correct hours', () {
      List<Date> x = new TimeIterable(new Date(2015,1,1), new Date(2015,1,5)).toList();
      List startHours = x.map((day) => day.start.hour).toList();
      expect(startHours.every((v) => v == 0), true);
    });

    test('daily for 5 days, backwards by one day', () {
      TimeIterable<Date> range = new TimeIterable(new Date(2015,1,5), new Date(2015,1,1), step: -1);
      expect(range.length, 5);
      expect(range.last, new Date(2015,1,1));
    });

    test('weekly for 3 weeks', () {
      TimeIterable<Date> range = new TimeIterable(new Date(2015,9,1), new Date(2015,9,20), step: 7);
      expect(range.length, 3);
      expect(range.last, new Date(2015,9,15));
    });

    test('monthly for 12 months', () {
      TimeIterable<Month> range = new TimeIterable(new Month(2015,1), new Month(2015,12));
      expect(range.length, 12);
      expect(range.elementAt(4), new Month(2015,5));
    });


  });
}



main() async {
  Map env = Platform.environment;
  String tzdb = env['HOME'] + '/.pub-cache/hosted/pub.dartlang.org/timezone-0.4.3/lib/data/2015b_all.tzf';
  await initializeTimeZone(tzdb);

  await testDate();
  await testDateIterable();
}
