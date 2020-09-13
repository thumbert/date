library month;

import 'package:date/date.dart';
import 'package:intl/intl.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/time_ordering.dart';
import 'package:date/src/interval.dart';
import 'package:timezone/timezone.dart';

/// Class representing a calendar Month implemented as an Interval.
class Month extends Interval implements TimeOrdering<Month>, Additive<Month> {
  int _value;
  int _year;
  int _month; // between Jan=1 to Dec=12
  Location _location;

  static final DateFormat _defaultFmt = DateFormat('MMMyy');
  static final DateFormat _isoFmt = DateFormat('yyyy-MM');

  static Month current({DateTime datetime, Location location}) {
    datetime ??= DateTime.now();
    location ??= UTC;
    return Month(datetime.year, datetime.month, location: location);
  }

  /// Creates a new [Month] object.  Months are [Interval]s.
  /// The default timezone is UTC.
  /// Specify the timezone for the month
  /// if you want to split/aggregate months.
  Month(int year, int month, {Location location})
      : super(TZDateTime.utc(year, month), TZDateTime.utc(year, month + 1)) {
    _value = year * 12 + month;
    _year = year;
    _month = month;
    if (location == null) {
      _location = UTC;
    } else {
      _location = location;
    }
  }

  /// Parse a string into a Month in the UTC timezone.  The default format is 'MMMyy'.
  static Month parse(String s,
      {@deprecated DateFormat fmt, Location location}) {
    return parseMonth(s, location: location);
  }

  /// Creates a new Month object from a DateTime.  The Month will contain the [datetime].
  Month.fromTZDateTime(TZDateTime datetime)
      : super(TZDateTime.utc(datetime.year, datetime.month),
            TZDateTime.utc(datetime.year, datetime.month + 1)) {
    _value = datetime.year * 12 + datetime.month;
    _year = datetime.year;
    _month = datetime.month;
    _location = datetime.location;
  }

  int _calcYear(int x) => (x - 1) ~/ 12;
  int _calcMonth(int x) => (x - 1) % 12 + 1;

  Location get location => _location;

  /// Get the datetime corresponding to the beginning of this month.
  /// The default timezone is UTC unless specified otherwise.
  @override
  TZDateTime get start => TZDateTime(location, _year, _month);
  @override
  TZDateTime get end => TZDateTime(location, _year, _month + 1);

  /// Get the first day of the month.
  Date get startDate => Date(_year, _month, 1, location: _location);

  /// Get the last day of the month.
  Date get endDate => next.startDate.subtract(1);

  Month get previous =>
      Month(_calcYear(_value - 1), _calcMonth(_value - 1), location: _location);

  /// Return the previous [n] months ending on this month.
  List<Month> previousN(int n) {
    var out = <Month>[];
    for (var i = n; i > 0; i--) {
      out.add(subtract(i));
    }
    return out;
  }

  Month get next =>
      Month(_calcYear(_value + 1), _calcMonth(_value + 1), location: _location);

  /// Return the next [n] months starting on this month.
  List<Month> nextN(int n) {
    var out = <Month>[];
    for (var i = 1; i <= n; i++) {
      out.add(add(i));
    }
    return out;
  }

  /// Return all months starting from this month up to [month] inclusive.
  /// If [month] is before [this] throw.
  List<Month> upTo(Month month) {
    if (month.isBefore(this)) {
      throw ArgumentError('Month $month is before $this');
    }
    var out = <Month>[];
    var nextM = this;
    while (!month.isBefore(nextM)) {
      out.add(nextM);
      nextM = nextM.add(1);
    }
    return out;
  }

  /// Get a list with all the Mondays in the month
  List<Date> mondays() {
    var out = <Date>[];
    var dow = startDate.weekday;
    if (dow == 1) {
      // month starts on a Monday
      out.add(startDate);
    } else {
      // add the first Monday
      out.add(startDate.add(8 - dow));
    }
    var end1 = endDate.add(1);
    var candidate = out.last.add(7);
    while (candidate.isBefore(end1)) {
      out.add(candidate);
      candidate = candidate.add(7);
    }
    return out;
  }

  @override
  Month add(int months) =>
      Month(_calcYear(_value + months), _calcMonth(_value + months),
          location: _location);
  Month subtract(int months) =>
      Month(_calcYear(_value - months), _calcMonth(_value - months),
          location: _location);

  @override
  bool isBefore(Month other) => _value < other._value;
  @override
  bool isAfter(Month other) => _value > other._value;
  @override
  bool operator ==(dynamic other) {
    if (other is! Month) return false;
    Month month = other;
    return _value == month._value && location == month.location;
  }

  @override
  int get hashCode => _value;

  int get year => _year;
  int get month => _month;

  /// Days of the month as list.
  List<Date> days() => splitLeft((dt) => Date.fromTZDateTime(dt));

  /// Format a month.  The default format is MMMyy.
  @override
  String toString([DateFormat fmt]) {
    fmt ??= _defaultFmt;
    return fmt.format(start);
  }

  /// Format a month using the yyyy-MM format.
  String toIso8601String() => _isoFmt.format(start);

  Interval toInterval() => Interval(start, end);
}
