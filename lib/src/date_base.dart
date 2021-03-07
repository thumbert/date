// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library date.base;

import 'package:date/src/date_parse.dart';
import 'package:timezone/timezone.dart';
import 'package:intl/intl.dart';
import 'month.dart';
import 'time_ordering.dart';
import 'interval.dart';
import 'hour.dart';

///A simple Date class.  No worries about the time of the day, time zones, etc.
///Days are counted as integers from an origin, set to '1970-01-01'.
class Date extends Interval implements TimeOrdering<Date>, Additive<Date> {
  int year;
  int month;
  int day;
  late int _value; // number of days since origin 1970-01-01
  int? _dayOfWeek;

  /// Default string format is the ISO `yyyy-MM-dd`.
  static final DateFormat _defaultFmt = DateFormat('yyyy-MM-dd');
  static final int _ORIGIN = 2440588; // 1970-01-01 is day zero
  static final Duration D1 = Duration(days: 1);

  /// Construct a [Date] from parts.
  Date(this.year, this.month, this.day, {required Location location})
      : super(TZDateTime(location, year, month, day),
            TZDateTime(location, year, month, day + 1)) {
    _simpleValidation();
    _calcValue();
  }

  /// Construct a [Date] from a DateTime.  Return the Date that contains this
  /// datetime.
  Date.fromTZDateTime(TZDateTime datetime)
      : year = datetime.year,
        month = datetime.month,
        day = datetime.day,
        super(
            TZDateTime(
                datetime.location, datetime.year, datetime.month, datetime.day),
            TZDateTime(datetime.location, datetime.year, datetime.month,
                datetime.day + 1)) {
    _calcValue();
  }

  /// A convenience constructor for utc dates
  Date.utc(this.year, this.month, this.day)
      : super(TZDateTime(UTC, year, month, day),
            TZDateTime(UTC, year, month, day + 1)) {
    _simpleValidation();
    _calcValue();
  }

  /// Return today's date.
  static Date today({required Location location}) {
    var now = DateTime.now();
    return Date(now.year, now.month, now.day, location: location);
  }

  /// Construct a date given the number of days since the origin 1970-01-01.
  /// Can't make this a constructor because I have problems setting the start/end
  /// of the superclass in the correct local timezone.
  static Date fromJulianDay(int value, {Location? location}) {
    var startZ = DateTime.fromMillisecondsSinceEpoch(1000 * 24 * 3600 * value,
        isUtc: true);
    location = location ?? UTC;
    return Date(startZ.year, startZ.month, startZ.day, location: location);
  }

  /// A convenience method to convert Excel dates (origin 1900-01-01)
  static Date fromExcel(int value, {Location? location}) {
    var startZ = DateTime.fromMillisecondsSinceEpoch(
        1000 * 24 * 3600 * (value - 25569),
        isUtc: true);
    location = location ?? UTC;
    return Date(startZ.year, startZ.month, startZ.day, location: location);
  }

  ///Constructs a new [Date] instance.
  ///Throws a [FormatException] if the input cannot be parsed.
  ///
  ///The accepted inputs are currently:
  ///
  /// A date: A signed four-to-six digit year, two digit month and
  /// two digit day, optionally separated by `-` characters.
  /// Examples: "19700101", "-0004-12-24", "81030-04-01".
  /// * yyyy-mm-dd format is accepted
  /// * mm/dd/yyyy format is accepted,
  /// * ddMMMyy format is accepted.
  static Date parse(String input,
      {Location? location, @deprecated DateFormat? fmt}) {
    return parseDate(input, location: location);
  }

  ///Constructs a new [Date] instance.
  ///Returns null if the input cannot be parsed.
  ///
  ///The accepted inputs are currently:
  ///
  /// A date: A signed four-to-six digit year, two digit month and
  /// two digit day, optionally separated by `-` characters.
  /// Examples: "19700101", "-0004-12-24", "81030-04-01".
  /// * yyyy-mm-dd format is accepted
  /// * mm/dd/yyyy format is accepted,
  /// * ddMMMyy format is accepted.
  static Date? tryParse(String input, {Location? location}) {
    return tryParseDate(input, location: location);
  }

  /// julian date
  int get value => _value;

  Location get location => start.location;

  /// The calculation to go from the triple (year, month, day) to a Julian
  /// date is taken from the R package
  /// [chron](http://CRAN.R-project.org/package=chron).
  void _calcValue() {
    // code from julian date in the S book (p.269)
    var y = year + (month > 2 ? 0 : -1);
    var m = month + (month > 2 ? -3 : 9);
    var c = y ~/ 100;
    var ya = y - 100 * c;

    _value = (146097 * c) ~/ 4 +
        (1461 * ya) ~/ 4 +
        (153 * m + 2) ~/ 5 +
        day +
        1721119 -
        _ORIGIN;
  }

  /// Return the previous day.
  Date get previous => Date.fromJulianDay(_value - 1, location: location);

  /// Return the previous [n] days ending on this date.
  List<Date> previousN(int n) {
    var out = <Date>[];
    for (var i = n; i > 0; i--) {
      out.add(subtract(i));
    }
    return out;
  }

  /// Return the next day.
  Date get next => Date.fromJulianDay(value + 1, location: location);

  /// Return the next [n] days starting on this date. [n] needs to be greater
  /// than 0.
  List<Date> nextN(int n) {
    var out = <Date>[];
    for (var i = 1; i <= n; i++) {
      out.add(add(i));
    }
    return out;
  }

  /// Return all dates starting from this date up to [date] inclusive.
  /// If [date] is before [this] throw.
  List<Date> upTo(Date date) {
    if (date.isBefore(this)) {
      throw ArgumentError('Date $date is before $this');
    }
    var out = <Date>[];
    var nextD = this;
    while (!date.isBefore(nextD)) {
      out.add(nextD);
      nextD = nextD.add(1);
    }
    return out;
  }

  /// Add a number of days to this date.
  @override
  Date add(int step) => Date.fromJulianDay(_value + step, location: location);

  /// Subtract a number of days from this date.
  Date subtract(int step) =>
      Date.fromJulianDay(value - step, location: location);

  /// Get the beginning of the month.
  Date get beginningOfMonth => Date(year, month, 1, location: location);

  /// Get the [Month] this [Date] belongs to.
  Month currentMonth() {
    return Month(year, month, location: location);
  }

  @override
  bool isBefore(Date other) => _value < other._value;
  @override
  bool isAfter(Date other) => _value > other._value;

  @override
  bool operator ==(dynamic other) {
    if (other is! Date) return false;
    var date = other;
    return date._value == _value && location == date.location;
  }

  @override
  int get hashCode => _value;

  /// Return the day of the week.  Mon=1, ... Sat=6, Sun=7.
  int get weekday {
    if (_dayOfWeek == null) _calcDayOfWeek();
    return _dayOfWeek!;
  }

  void _calcDayOfWeek() {
    var ix = year + ((month - 14) / 12).truncate();
    var jx =
        ((13 * (month + 10 - (month + 10) ~/ 13 * 12) - 1) / 5).truncate() +
            day +
            77 +
            (5 * (ix - (ix ~/ 100) * 100)) ~/ 4 +
            ix ~/ 400 -
            (ix ~/ 100) * 2;
    jx = jx % 7;
    if (jx == 0) jx = 7; // Make Sun = 7

    _dayOfWeek = jx;
  }

  /// Return the day of the year.  1-Jan is day 1 of the year.
  int dayOfYear() => value - Date(year, 1, 1, location: UTC).value + 1;

  /// If this [Date] is Sat or Sun, return true.  False otherwise.
  bool isWeekend() => weekday >= 6 ? true : false;

  /// Convert to a regular SDK [DateTime] object at midnight.
  DateTime toDateTime({isUtc = false}) {
    if (isUtc) {
      return DateTime.utc(year, month, day);
    } else {
      return DateTime(year, month, day);
    }
  }

  /// Convert to an Excel integer
  int toExcel() {
    return _value + 25569;
  }

  /// Get all the hours in this day
  List<Hour> hours() => splitLeft((dt) => Hour.beginning(dt)).cast<Hour>();

  @override
  String toString([DateFormat? fmt]) {
    fmt ??= _defaultFmt;
    return fmt.format(DateTime(year, month, day));
  }

  Interval toInterval() => Interval(start, end);

  void _simpleValidation() {
    if (month > 12 || month < 1) {
      throw FormatException('Invalid month value $month', month);
    }
    if (day > 31 || day < 1) {
      throw FormatException('Invalid day value $day', day);
    }
  }
}
