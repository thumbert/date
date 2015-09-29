library month;

import 'package:intl/intl.dart';
import 'package:date/src/time_iterable.dart';
import 'package:date/src/date_base.dart';

/**
 * Class representing a calendar Month.
 *
 *
 */
class Month extends Comparable<Month> {

  int _value;
  int _year;
  int _month;  // between Jan=1 to Dec=12

  static final DateFormat DEFAULT_FMT = new DateFormat('MMMyy');
  static final DateFormat fmt = DEFAULT_FMT;
  static final Duration H1 = new Duration(hours: 1);

  static Month current( {DateTime datetime} ) {
    if (datetime == null)
      datetime = new DateTime.now();
    return new Month(datetime.year, datetime.month);
  }


  /**
   * Creates a new Month object.
   */
  Month(int year, int month) {
    _value = year*12 + month;
    _year  = year;
    _month = month;
  }

  /**
   * Creates a new Month object from a DateTime.  The Month will contain the [datetime].
   */
  Month.fromDateTime(DateTime datetime) {
    _value = datetime.year*12 + datetime.month;
    _year  = datetime.year;
    _month = datetime.month;
  }

  int _calcYear(int x)  => (x-1) ~/ 12;
  int _calcMonth(int x) => (x-1) % 12 + 1;

  Date get startDate => new Date(_year, _month, 1);
  Date get endDate => next.startDate.subtract(1);

  Month get previous => new Month(_calcYear(_value-1), _calcMonth(_value-1));
  Month get next => new Month(_calcYear(_value+1), _calcMonth(_value+1));
  Month add(int months) => new Month(_calcYear(_value+months), _calcMonth(_value+months));
  Month subtract(int months) => new Month(_calcYear(_value-months), _calcMonth(_value-months));

//  bool operator <(Month other)  => _value < other._value;
//  bool operator <=(Month other) => _value <= other._value;
//  bool operator >(Month other)  => _value > other._value;
//  bool operator >=(Month other) => _value >= other._value;
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

  /**
   * Days of the month as an [Iterable].
   */
  Iterable<Date> days() => new TimeIterable(startDate, endDate);

  String toString() => fmt.format(new DateTime(year, month));

  TimeIterator get dateIterator => new TimeIterator(startDate, endDate, step: 1);
}

