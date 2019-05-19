library month;

import 'package:intl/intl.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/time_ordering.dart';
import 'package:date/src/interval.dart';
import 'package:timezone/timezone.dart';

/// Class representing a calendar Month implemented as an Interval.
class Month extends Interval
    implements TimeOrdering<Month>, Additive<Month> {
  int _value;
  int _year;
  int _month; // between Jan=1 to Dec=12
  Location _location;

  static final DateFormat _defaultFmt = new DateFormat('MMMyy');
  static final DateFormat _isoFmt = new DateFormat('yyyy-MM');

  static Month current({DateTime datetime}) {
    datetime ??= new DateTime.now();
    return new Month(datetime.year, datetime.month);
  }

  /// Creates a new [Month] object.  Months are [Interval]s.
  /// The default timezone is UTC.
  /// Specify the timezone for the month
  /// if you want to split/aggregate months.
  Month(int year, int month, {Location location})
      : super(new TZDateTime.utc(year, month), new TZDateTime.utc(year, month + 1)) {
    _value = year * 12 + month;
    _year = year;
    _month = month;
    if (location == null)
      _location = UTC;
    else
      _location = location;
  }

  /// Parse a string into a Month in the UTC timezone.  The default format is 'MMMyy'.
  static Month parse(String s, {DateFormat fmt, Location location}) {
    fmt ??= _defaultFmt;
    location ??= UTC;
    var dt = fmt.parseUtc(s);
    return Month(dt.year, dt.month, location: location);
  }

  /// Creates a new Month object from a DateTime.  The Month will contain the [datetime].
  Month.fromTZDateTime(TZDateTime datetime)
      : super(new TZDateTime.utc(datetime.year, datetime.month),
            new TZDateTime.utc(datetime.year, datetime.month + 1)) {
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
  TZDateTime get start => new TZDateTime(location, _year, _month);
  TZDateTime get end => new TZDateTime(location, _year, _month + 1);

  /// Get the first day of the month.
  Date get startDate => new Date(_year, _month, 1, location: _location);

  /// Get the last day of the month.
  Date get endDate => next.startDate.subtract(1);

  Month get previous =>
      new Month(_calcYear(_value - 1), _calcMonth(_value - 1), location: _location);

  /// Return the previous [n] months ending on this month.
  List<Month> previousN(int n) {
    var out = <Month>[];
    for (int i=n; i>0; i--) {
      out.add(this.subtract(i));
    }
    return out;
  }

  Month get next => Month(_calcYear(_value + 1), _calcMonth(_value + 1), location: _location);

  /// Return the next [n] months starting on this month.
  List<Month> nextN(int n) {
    var out = <Month>[];
    for (int i=1; i<=n; i++) {
      out.add(this.add(i));
    }
    return out;
  }

  Month add(int months) =>
      new Month(_calcYear(_value + months), _calcMonth(_value + months), location: _location);
  Month subtract(int months) =>
      new Month(_calcYear(_value - months), _calcMonth(_value - months), location: _location);

  bool isBefore(Month other) => _value < other._value;
  bool isAfter(Month other) => _value > other._value;
  bool operator ==(dynamic other) {
    if (other is! Month) return false;
    Month month = other;
    return _value == month._value && location == month.location;
  }

  int get hashCode => _value;

  int get year => _year;
  int get month => _month;

  /// Days of the month as list.
  List<Date> days() => splitLeft((dt) => new Date.fromTZDateTime(dt)).cast<Date>();

  /// Format a month.  The default format is MMMyy.
  String toString([DateFormat fmt]) {
    fmt ??= _defaultFmt;
    return fmt.format(start);
  }

  /// Format a month using the yyyy-MM format.
  String toIso8601String() => _isoFmt.format(start);

  Interval toInterval() => new Interval(start, end);
}
