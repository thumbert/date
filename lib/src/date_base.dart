// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library date.base;

import 'package:timezone/timezone.dart';
import 'package:intl/intl.dart';
import 'month.dart';
import 'time_ordering.dart';
import 'interval.dart';
import 'hour.dart';

///A simple Date class.  No worries about the time of the day, time zones, etc.
///Days are counted as integers from an origin, set to '1970-01-01'.
class Date extends Interval
    implements TimeOrdering<Date>, Additive<Date> {
  int _year;
  int _month;
  int _day;
  int _value; // number of days since origin 1970-01-01
  int _dayOfWeek;
  Location _location;

  /// Default string format is the ISO `yyyy-MM-dd`.
  static final DateFormat _defaultFmt = DateFormat('yyyy-MM-dd');
  static final int _ORIGIN = 2440588; // 1970-01-01 is day zero
  static final Duration D1 = Duration(days: 1);

  /// Return today's date.
  static Date today({Location location}) {
    DateTime now = new DateTime.now();
    return new Date(now.year, now.month, now.day, location: location);
  }

  /// Construct a [Date] from parts.
  Date(int year, int month, int day, {Location location})
      : super(new TZDateTime.utc(year, month, day),
            new TZDateTime.utc(year, month, day + 1)) {
    _year = year;
    _month = month;
    _day = day;
    _simpleValidation();
    _calcValue();
    if (location == null)
      _location = UTC;
    else
      _location = location;
  }

  /// Construct a [Date] from a DateTime.  Return the Date that contains this
  /// datetime.
  Date.fromTZDateTime(TZDateTime datetime)
      : super(TZDateTime.utc(datetime.year, datetime.month, datetime.day),
            TZDateTime.utc(datetime.year, datetime.month, datetime.day + 1)) {
    _year = datetime.year;
    _month = datetime.month;
    _day = datetime.day;
    _calcValue();
    _location = datetime.location;
  }

  /// Construct a date given the number of days since the origin 1970-01-01.
  /// Can't make this a constructor because I have problems setting the start/end
  /// of the superclass in the correct local timezone.
  static Date fromJulianDay(int value, {Location location}) {
    var startZ = DateTime.fromMillisecondsSinceEpoch(
        1000 * 24 * 3600 * value,
        isUtc: true);
    location = location ?? UTC;
    return Date(startZ.year, startZ.month, startZ.day, location: location);
  }

  ///Constructs a new [Date] instance based on [formattedString].
  ///Throws a [FormatException] if the input cannot be parsed.
  ///
  ///The function parses a subset of ISO 8601
  ///which includes the subset accepted by RFC 3339.
  ///
  ///The accepted inputs are currently:
  ///
  /// A date: A signed four-to-six digit year, two digit month and
  /// two digit day, optionally separated by `-` characters.
  /// Examples: "19700101", "-0004-12-24", "81030-04-01".
  ///
  static Date parse(String formattedString, {Location location}) {
    final RegExp re = RegExp(r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)');

    Match match = re.firstMatch(formattedString);
    if (match != null) {
      int years = int.parse(match[1]);
      int month = int.parse(match[2]);
      int day = int.parse(match[3]);
      return Date(years, month, day, location: location);
    } else {
      throw FormatException("Invalid date format", formattedString);
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

  /// The calculation to go from the triple (year, month, day) to a Julian
  /// date is taken from the R package
  /// [chron](http://CRAN.R-project.org/package=chron).
  void _calcValue() {
    // code from julian date in the S book (p.269)
    var y = _year + (_month > 2 ? 0 : -1);
    var m = _month + (_month > 2 ? -3 : 9);
    var c = y ~/ 100;
    var ya = y - 100 * c;

    _value = (146097 * c) ~/ 4 +
        (1461 * ya) ~/ 4 +
        (153 * m + 2) ~/ 5 +
        _day +
        1721119 -
        _ORIGIN;
  }

  Location get location => _location;

  /// Get the datetime corresponding to the beginning of this month.
  /// The default timezone is UTC unless specified otherwise.
  TZDateTime get start => new TZDateTime(location, _year, _month, _day);
  TZDateTime get end => new TZDateTime(location, _year, _month, _day + 1);

  /// Return the previous day.
  Date get previous => Date.fromJulianDay(_value - 1, location: _location);

  /// Return the previous [n] days ending on this date.
  List<Date> previousN(int n) {
    var out = <Date>[];
    for (int i=n; i>0; i--) {
      out.add(this.subtract(i));
    }
    return out;
  }

  /// Return the next day.
  Date get next => Date.fromJulianDay(value + 1, location: _location);

  /// Return the next [n] days starting on this date. [n] needs to be greater
  /// than 0.
  List<Date> nextN(int n) {
    var out = <Date>[];
    for (int i=1; i<=n; i++) {
      out.add(this.add(i));
    }
    return out;
  }
    
  /// Return all dates starting from this date up to [date] inclusive.
  /// If [date] is before [this] throw.
  List<Date> upTo(Date date) {
    if (date.isBefore(this))
      throw ArgumentError('Date $date is before $this');
    var out = <Date>[];
    var nextD = this;
    while (!date.isBefore(nextD)) {
      out.add(nextD);
      nextD = nextD.add(1);
    }
    return out;
  }  
    

  /// Add a number of days to this date.
  Date add(int step) => Date.fromJulianDay(_value + step, location: _location);

  /// Subtract a number of days from this date.
  Date subtract(int step) => Date.fromJulianDay(value - step, location: _location);

  /// Get the beginning of the month.
  Date get beginningOfMonth => new Date(_year, _month, 1, location: _location);

  /// Get the [Month] this [Date] belongs to.
  Month currentMonth() => new Month(_year, _month, location: _location);

  bool isBefore(Date other) => _value < other._value;
  bool isAfter(Date other) => _value > other._value;

  bool operator ==(dynamic other) {
    if (other is! Date) return false;
    Date date = other;
    return date._value == _value && location == date.location;
  }
  //int compareTo(Date other) => this.value.compareTo(other.value);
  int get hashCode => _value;

  /// Return the day of the week.  Mon=1, ... Sat=6, Sun=7.
  int get weekday {
    if (_dayOfWeek == null) _calcDayOfWeek();
    return _dayOfWeek;
  }

  void _calcDayOfWeek() {
    var ix = _year + ((_month - 14) / 12).truncate();
    var jx =
        ((13 * (_month + 10 - (_month + 10) ~/ 13 * 12) - 1) / 5).truncate() +
            _day +
            77 +
            (5 * (ix - (ix ~/ 100) * 100)) ~/ 4 +
            ix ~/ 400 -
            (ix ~/ 100) * 2;
    jx = jx % 7;
    if (jx == 0) jx = 7; // Make Sun = 7

    _dayOfWeek = jx;
  }

  /// Return the day of the year.  1-Jan is day 1 of the year. 
  int dayOfYear() => value - Date(_year, 1, 1).value + 1;

  /// If this [Date] is Sat or Sun, return true.  False otherwise.
  bool isWeekend() => weekday >= 6 ? true : false;

  /// Convert to a regular SDK [DateTime] object at midnight.
  DateTime toDateTime({isUtc: false}) {
    if (isUtc) {
      return DateTime.utc(year, month, day);
    } else {
      return DateTime(year, month, day);
    }
  }

  /// Get all the hours in this day
  List<Hour> hours() => splitLeft((dt) => Hour.beginning(dt)).cast<Hour>();

  String toString([DateFormat fmt]) {
    fmt ??= _defaultFmt;
    return fmt.format(DateTime(_year, _month, _day));
  }

  Interval toInterval() => Interval(start, end);

  _simpleValidation() {
    if (_month > 12 || _month < 1)
      throw FormatException('Invalid month value $_month', _month);
    if (_day > 31 || _day < 1)
      throw FormatException('Invalid day value $_day', _day);
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
