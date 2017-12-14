// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.


library date.base;

import 'package:intl/intl.dart';
import 'month.dart';
import 'time_ordering.dart';
import 'interval.dart';



 ///A simple Date class.  No worries about the time of the day, time zones, etc.
 ///Days are counted as integers from an origin, set to '1970-01-01'.
class Date extends Interval implements TimeOrdering<Date>, ComparableWithAdd<Date> {

  int _year;
  int _month;
  int _day;
  int _value;  // number of days since origin 1970-01-01
  int _dayOfWeek;



  /// Default string format is the ISO `yyyy-MM-dd`.
  static final DateFormat DEFAULT_FMT = new DateFormat('yyyy-MM-dd');
  static final int _ORIGIN = 2440588; // 1970-01-01 is day zero
  static final Duration D1 = new Duration(days: 1);


  /// Use this [DateFormat] to change the `toString()` output of this date.
  static DateFormat fmt = DEFAULT_FMT;


  /// Return today's date.
  static Date today() {
    DateTime now = new DateTime.now();
    return new Date(now.year, now.month, now.day);
  }


  /// Construct a [Date] from parts.
  Date(int year, int month, int day): super(new DateTime(year, month, day), new DateTime(year, month, day+1)) {
    _year = year;
    _month = month;
    _day = day;
    _simpleValidation();
    _calcValue();
  }


  /// Construct a [Date] from a DateTime.
  /// TODO: I think this is dangerous. Date needs to call the super in UTC. 
  Date.fromDateTime(DateTime start): super(start, start.add(D1)) {
    _year = start.year;
    _month = start.month;
    _day = start.day;
    _calcValue();
  }


  /// Construct a date given the number of days since the origin 1970-01-01.
  /// Can't make this a constructor because I have problems setting the start/end
  /// of the superclass in the correct local timezone.
  static Date fromJulianDay(int value) {
    var startZ = new DateTime.fromMillisecondsSinceEpoch(1000*24*3600*value, isUtc: true);
    return new Date(startZ.year, startZ.month, startZ.day);
  }

  /**
   * Constructs a new [Date] instance based on [formattedString].
   *
   * Throws a [FormatException] if the input cannot be parsed.
   *
   * The function parses a subset of ISO 8601
   * which includes the subset accepted by RFC 3339.
   *
   * The accepted inputs are currently:
   *
   * * A date: A signed four-to-six digit year, two digit month and
   *   two digit day, optionally separated by `-` characters.
   *   Examples: "19700101", "-0004-12-24", "81030-04-01".
   */
  static Date parse(String formattedString) {
    final RegExp re = new RegExp(
        r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)');

    Match match = re.firstMatch(formattedString);
    if (match != null) {
      int years = int.parse(match[1]);
      int month = int.parse(match[2]);
      int day = int.parse(match[3]);
      return new Date(years, month, day);
    } else {
      throw new FormatException("Invalid date format", formattedString);
    }
  }

  /// the year of the date
  int get year => _year;
  /// month of the year for this date
  int get month => _month;
  /// day of the month for this date
  int get day => _day;
  /// julian date
  int get value => _value;


  void _calcValue() {
    // code from julian date in the S book (p.269)
    var y = _year + (_month > 2 ? 0 : -1);
    var m = _month + (_month > 2 ? -3 : 9);
    var c = y ~/ 100;
    var ya = y - 100*c;

    _value = (146097*c) ~/ 4 + (1461*ya) ~/ 4 + (153 * m + 2) ~/ 5 + _day + 1721119 - _ORIGIN;
  }


  /// Return the previous day.
  Date get previous => Date.fromJulianDay(_value - 1);


  /// Return the next day.
  Date get next => Date.fromJulianDay( value + 1);


  /// Add a number of days to this date.
  Date add(int step) => Date.fromJulianDay(_value + step);


  /// Subtract a number of days from this date.
  Date subtract(int step) => Date.fromJulianDay(value - step);


  /// Get the beginning of the month.
  Date get beginningOfMonth => new Date(_year, _month, 1);


  /// Get the [Month] this [Date] belongs to.
  Month currentMonth() => new Month(_year, _month);


  bool isBefore(Date other) => _value < other._value;
  bool isAfter(Date other) => _value > other._value;
  bool operator ==(Date other) => other != null && other._value == _value;
  int compareTo(Date other)    => this.value.compareTo(other.value);
  int get hashCode => _value;


  /// Return the day of the week.  Mon=1, ... Sat=6, Sun=7.
  int get weekday {
    if (_dayOfWeek == null) _calcDayOfWeek();
    return _dayOfWeek;
  }

  void _calcDayOfWeek() {
    var ix = _year + ((_month-14)/12).truncate();
    var jx = ((13 * (_month + 10 - (_month + 10) ~/ 13 * 12) - 1)/5).truncate()
    + _day + 77 + (5 * (ix - (ix ~/ 100) * 100)) ~/ 4
    + ix ~/ 400 - (ix ~/ 100) * 2;
    jx = jx % 7;
    if (jx == 0) jx = 7;  // Make Sun = 7

    _dayOfWeek = jx;
  }

  /// Return the day of the year.
  int dayOfYear() => value - new Date(_year, 1, 1).value + 1;

  /// If this [Date] is Sat or Sun, return true.  False otherwise.
  bool isWeekend() => [0,6].contains(weekday);


  /// Convert to a regular SDK [DateTime] object at midnight.
  DateTime toDateTime({isUtc: false}) {
    if (isUtc) return new DateTime.utc(year, month, day);
    else return new DateTime(year, month, day);
  }

  String toString() => fmt.format(new DateTime(_year, _month, _day));

  Interval toInterval() => new Interval(start, end);

  _simpleValidation() {
    if (_month > 12 || _month < 1)
      throw new FormatException('Invalid month value $_month', _month);
    if (_day > 31 || _day < 1)
      throw new FormatException('Invalid day value $_day', _day);
  }
}

// calculate year, month, day when you know the _value
//  void _calcYearMonthDay() {
//    var j = value + _ORIGIN - 1721119;
//    _year = (4 * j - 1) ~/ 146097;
//    j = 4 * j - 1 - 146097 * _year;
//    _day = j ~/ 4;
//    j = (4 * _day + 3) ~/ 1461;
//    _day = (4 * _day + 3) - 1461 * j;
//    _day = (_day + 4) ~/ 4;
//    _month = (5 * _day - 3) ~/ 153;
//    _day = (5 * _day - 3) - 153 * _month;
//    _day = (_day + 5) ~/ 5;
//    _year = 100 * _year + j;
//    _year = _year + (_month < 10 ? 0 : 1);
//    _month = _month + (_month < 10 ? 3 : -9);
//  }
