// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.


library date.base;

import 'package:intl/intl.dart';
import 'package:date/src/month.dart';
import 'package:date/src/time_ordering.dart';

/**
 * A simple Date class.  No worries about the time of the day, time zones, etc.
 */
class Date extends Comparable<Date> implements TimeOrdering<Date> {

  int _year;
  int _month;
  int _day;
  int _value;  // number of days since origin 1970-01-01
  int _dayOfWeek;

  /**
   * Default string format is the ISO `yyyy-MM-dd`.
   */
  static final DateFormat DEFAULT_FMT = new DateFormat('yyyy-MM-dd');
  static final int _ORIGIN = 2440588; // 1970-01-01 is day zero

  /**
   * Use this [DateFormat] to change the `toString()` output of this date.
   */
  static DateFormat fmt = DEFAULT_FMT;

  /**
   * Return today's date.
   */
  static Date today() {
    DateTime now = new DateTime.now();
    return new Date(now.year, now.month, now.day);
  }

  /**
   * Construct a [Date] from parts.
   */
  Date(int year, int month, int day) {
    _year = year;
    _month = month;
    _day = day;
    _simpleValidation();
    _calcValue();
  }

  /**
   * Construct a [Date] from a DateTime.
   */
  Date.fromDateTime(DateTime start) {
    _year = start.year;
    _month = start.month;
    _day = start.day;
    _calcValue();
  }

  /**
   * Construct a date given the number of days since the origin 1970-01-01.
   */
  Date.fromJulianDay(int value) {
    _value = value;
    _calcYearMonthDay();
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
      int parseIntOrZero(String matched) {
        if (matched == null) return 0;
        return int.parse(matched);
      }

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

  // calculate year, month, day when you know the _value
  void _calcYearMonthDay() {
    var j = value + _ORIGIN - 1721119;
    _year = (4 * j - 1) ~/ 146097;
    j = 4 * j - 1 - 146097 * _year;
    _day = j ~/ 4;
    j = (4 * _day + 3) ~/ 1461;
    _day = (4 * _day + 3) - 1461 * j;
    _day = (_day + 4) ~/ 4;
    _month = (5 * _day - 3) ~/ 153;
    _day = (5 * _day - 3) - 153 * _month;
    _day = (_day + 5) ~/ 5;
    _year = 100 * _year + j;
    _year = _year + (_month < 10 ? 0 : 1);
    _month = _month + (_month < 10 ? 3 : -9);
  }

  void _calcValue() {
    // code from julian date in the S book (p.269)
    var y = _year + (_month > 2 ? 0 : -1);
    var m = _month + (_month > 2 ? -3 : 9);
    var c = y ~/ 100;
    var ya = y - 100*c;

    _value = (146097*c) ~/ 4 + (1461*ya) ~/ 4 + (153 * m + 2) ~/ 5 + _day + 1721119 - _ORIGIN;
  }

  /**
   * Return the previous day.
   */
  Date get previous => new Date.fromJulianDay(_value - 1);

  /**
   * Return the next day.
   */
  Date get next => new Date.fromJulianDay( value + 1);

  /**
   * Add a number of days to this date.
   */
  Date add(int step) => new Date.fromJulianDay(_value + step);

  /**
   * Subtract a number of days from this date.
   */
  Date subtract(int step) => new Date.fromJulianDay(value - step);

  /**
   * Get the beginning of the month.
   */
  Date get beginningOfMonth => new Date(_year, _month, 1);

  /**
   * Get the [Month] this [Date] belongs to.
   */
  Month currentMonth() => new Month(_year, _month);


  bool isBefore(Date other) => _value < other._value;
  bool isAfter(Date other) => _value > other._value;
  bool operator ==(Date other) => other != null && other._value == _value;
  int compareTo(Date other)    => this.value.compareTo(other.value);
  int get hashCode => _value;

  /**
   * Return the day of the week.  Mon=1, ... Sat=6, Sun=7.
   */
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

  // Return the day of the year.
  int dayOfYear() => value - new Date(_year, 1, 1).value + 1;

  // if this [Date] is Sat or Sun, return true.  False otherwise.
  bool isWeekend() => [0,6].contains(weekday);

  /**
   * Convert to a regular SDK [DateTime] object at midnight.
   */
  DateTime toDateTime({isUtc: false}) {
    if (isUtc) return new DateTime.utc(year, month, day);
    else return new DateTime(year, month, day);
  }

  String toString() => fmt.format(new DateTime(_year, _month, _day));

  _simpleValidation() {
    if (_month > 12 || _month < 1)
      throw new FormatException('Invalid month value $_month', _month);
    if (_day > 31 || _day < 1)
      throw new FormatException('Invalid day value $_day', _day);
  }

//  Iterable<Hour> hours({Location location}) {
//    new TimeIterable(new Hour.beginning())
//  }
}

