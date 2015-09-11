// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library test.date;

import 'package:test/test.dart';
import 'package:date/date.dart';
import 'package:intl/intl.dart';

test_date() {
  group("Test Date: ", () {
    test("From year month day to Julian day", () {
      expect(new Date(1970, 1, 1).value, 0);
      expect(new Date(2014, 1, 1).value, 16071);
      expect(new Date(1900, 1, 1).value, -25567);
      expect(new Date(2100, 1, 1).value, 47482);
    });

    test('parse a string', (){
      expect(Date.parse('20150101'), new Date(2015,1,1));
      expect(Date.parse('2015-01-03'), new Date(2015,1,3));
      expect(Date.parse('2015-0103'), new Date(2015,1,3));
      expect(Date.parse('20150229'), new Date(2015,3,1));  // !!! same as DateTime
    });

    test("From Julian day to year month day", () {
      Date d = new Date(2014, 5, 15);
      expect([d.year, d.month, d.day], [2014, 5, 15]);
      Date d2 = new Date.fromJulianDay(d.value);
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


    test('next/previous day', (){
      expect(new Date(2015, 2, 28).next, new Date(2015,3,1));
      expect(new Date(2015, 1, 1).previous, new Date(2014,12,31));
    });

    test('current/next/previous month', (){
      expect(new Date(2015,2,28).currentMonth, new Date(2015,2,1));
      expect(new Date(2015,2,28).nextMonth, new Date(2015,3,1));
      expect(new Date(2015,2,28).previousMonth, new Date(2015,1,1));
    });

    test("Date sequences", () {
      Date d1 = new Date(2014, 1, 1);
      expect(d1.toString(), "2014-01-01");
      expect(d1.next, new Date(2014, 1, 2));
      expect(new Date(2014, 1, 31).next, new Date(2014, 2, 1));
      expect(
          d1.seqTo(new Date(2014, 1, 10), step: 4).map((e) => e.toString()).join(','),
          "2014-01-01,2014-01-05,2014-01-09");
      expect(
          d1.seqLength(3, step: 4).map((e) => e.toString()).join(','),
          "2014-01-01,2014-01-05,2014-01-09");
    });

    test("Change the date display format", () {
      Date.fmt = new DateFormat("dMMMyy");
      expect(new Date(2014, 1, 1).toString(), "1Jan14");
    });

    test("Sort dates", (){
      var x = [new Date(2014,8,1), new Date(2014,12,1),
      new Date(2014,2,1)];
      x.sort();
      Date.fmt = Date.DEFAULT_FMT;
      expect(x.map((d) => d.toString()).join(","),
      "2014-02-01,2014-08-01,2014-12-01");
    });

    test("toSet() on a list of Dates", () {
      var x = [new Date(2014,1,1), new Date(2014,1,1)];
      expect(x.toSet().toList().length, 1);
    });

  });
}


main() => test_date();
