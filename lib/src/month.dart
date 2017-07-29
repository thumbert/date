library month;

import 'package:intl/intl.dart';
import 'package:date/src/time_iterable.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/time_ordering.dart';
import 'package:date/src/interval.dart';


/// Class representing a calendar Month.
class Month extends Interval implements TimeOrdering<Month>, ComparableWithAdd<Month> {

  int _value;
  int _year;
  int _month;  // between Jan=1 to Dec=12

  static final DateFormat DEFAULT_FMT = new DateFormat('MMMyy');
  static final DateFormat fmt = DEFAULT_FMT;

  static Month current( {DateTime datetime} ) {
    if (datetime == null)
      datetime = new DateTime.now();
    return new Month(datetime.year, datetime.month);
  }

  /// Creates a new Month object.
  Month(int year, int month): super(new DateTime(year, month), new DateTime(year, month+1))  {
    _value = year*12 + month;
    _year  = year;
    _month = month;
  }

  /// Parse a string into a Month.  The default format is 'MMMyy'.
  static Month parse(String s, {DateFormat fmt}) {
    fmt ??= DEFAULT_FMT;
    return new Month.fromDateTime(fmt.parse(s));
  }

  /// Creates a new Month object from a DateTime.  The Month will contain the [datetime].
  Month.fromDateTime(DateTime datetime): super(new DateTime(datetime.year, datetime.month),
      new DateTime(datetime.year, datetime.month+1)) {
    _value = datetime.year*12 + datetime.month;
    _year  = datetime.year;
    _month = datetime.month;
  }

  int _calcYear(int x)  => (x-1) ~/ 12;
  int _calcMonth(int x) => (x-1) % 12 + 1;

  /// get the local time corresponding to the beginning of this month.
  DateTime get start => new DateTime(_year, _month);
  /// get the first day of the month
  Date get startDate => new Date(_year, _month, 1);
  /// get the last day of the month
  Date get endDate => next.startDate.subtract(1);

  Month get previous => new Month(_calcYear(_value-1), _calcMonth(_value-1));
  Month get next => new Month(_calcYear(_value+1), _calcMonth(_value+1));
  Month add(int months) => new Month(_calcYear(_value+months), _calcMonth(_value+months));
  Month subtract(int months) => new Month(_calcYear(_value-months), _calcMonth(_value-months));

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
    } else if (this._value == other._value){
      res = 0;
    } else {
      res = 1;
    };

    return res;
  }


  /// Days of the month as an [Iterable].
  Iterable<Date> days() => new TimeIterable(startDate, endDate);

  String toString() => fmt.format(start);

  Interval toInterval() => new Interval(start, next.start);

  TimeIterator get dateIterator => new TimeIterator(startDate, endDate, step: 1);
}

