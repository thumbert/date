library month;

import 'package:intl/intl.dart';
import 'package:date/src/time_iterable.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/time_ordering.dart';
import 'package:date/src/interval.dart';
import 'package:timezone/timezone.dart';

/// Class representing a calendar Month implemented as an Interval.
class Month extends Interval
    implements TimeOrdering<Month>, ComparableWithAdd<Month> {

  int _value;
  int _year;
  int _month; // between Jan=1 to Dec=12
  Location location;

  static final DateFormat DEFAULT_FMT = new DateFormat('MMMyy');
  static final DateFormat fmt = DEFAULT_FMT;

  static Month current({DateTime datetime}) {
    datetime ??= new DateTime.now();
    return new Month(datetime.year, datetime.month);
  }

  /// Creates a new [Month] object.  Months are [Interval]s.
  /// The default timezone is UTC.
  /// Specify the timezone for the month
  /// if you want to split/aggregate months.
  Month(int year, int month, {this.location})
      : super(new DateTime(year, month),
            new DateTime(year, month + 1)) {
    _value = year * 12 + month;
    _year = year;
    _month = month;
    location ??= UTC;
  }

  /// Parse a string into a Month.  The default format is 'MMMyy'.
  static Month parse(String s, {DateFormat fmt}) {
    fmt ??= DEFAULT_FMT;
    return new Month.fromDateTime(fmt.parse(s));
  }

  /// Creates a new Month object from a DateTime.  The Month will contain the [datetime].
  Month.fromDateTime(DateTime datetime, {this.location})
      : super(new DateTime(datetime.year, datetime.month),
            new DateTime(datetime.year, datetime.month + 1)) {
    _value = datetime.year * 12 + datetime.month;
    _year = datetime.year;
    _month = datetime.month;
    location ??= UTC;
  }

  int _calcYear(int x) => (x - 1) ~/ 12;
  int _calcMonth(int x) => (x - 1) % 12 + 1;

  /// Get the datetime corresponding to the beginning of this month.
  /// The default timezone is UTC unless specified otherwise.
  DateTime get start => new TZDateTime(location, _year, _month);
  DateTime get end => new TZDateTime(location, _year, _month+1);

  /// Get the first day of the month.
  Date get startDate => new Date(_year, _month, 1);

  /// Get the last day of the month.
  Date get endDate => next.startDate.subtract(1);

  Month get previous =>
      new Month(_calcYear(_value - 1), _calcMonth(_value - 1));
  Month get next => new Month(_calcYear(_value + 1), _calcMonth(_value + 1));
  Month add(int months) =>
      new Month(_calcYear(_value + months), _calcMonth(_value + months));
  Month subtract(int months) =>
      new Month(_calcYear(_value - months), _calcMonth(_value - months));

  bool isBefore(Month other) => _value < other._value;
  bool isAfter(Month other) => _value > other._value;
  bool operator ==(Month other) => other != null && _value == other._value;

  int get hashCode => _value;

  int get year => _year;
  int get month => _month;

  int compareTo(Month other) {
    int res;
    if (this._value < other._value) {
      res = -1;
    } else if (this._value == other._value) {
      res = 0;
    } else {
      res = 1;
    }
    ;

    return res;
  }

  /// Days of the month as list.
  /// TODO: add a location for dates!
  List<Date> days() => splitLeft((dt) => new Date.fromDateTime(dt));

  String toString() => fmt.format(start);

  Interval toInterval() => new Interval(start, end);

  TimeIterator get dateIterator =>
      new TimeIterator(startDate, endDate, step: 1);
}
