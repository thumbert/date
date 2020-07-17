library term;

import 'package:date/date.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'term_parse.dart';

class Term {
  Interval _interval;

  /// A simple interval for a period between two dates, end date inclusive.
  Term(Date start, Date end) {
    _interval = Interval(start.start, end.end);
  }

  Term.parse(String x, Location location) {
    _interval = parseTerm(x, tzLocation: location);
  }

  Term.fromInterval(Interval interval) {
    if (!isMidnight(interval.start)) {
      throw ArgumentError('Interval start needs to be at midnight');
    }
    if (!isMidnight(interval.end)) {
      throw ArgumentError('Interval end needs to be at midnight');
    }
    _interval = interval;
  }

  /// Return a similar term that starts in year [year].
  /// For example, if term is 'Jul20-Aug20', it will return 'Jul18-Aug18' with
  /// start year 2018.   Or term 'Nov20-Mar21' will return 'Nov18-Mar19' with
  /// start year 2018.
  Term withStartYear(int year) {
    var _start = startDate;
    var newStart =
        Date(year, _start.month, _start.day, location: _start.location);
    var _end = endDate;
    var offset = _end.year - _start.year;
    var newEnd =
        Date(year + offset, _end.month, _end.day, location: _end.location);
    return Term(newStart, newEnd);
  }

  List<Date> days() => _interval.splitLeft((dt) => Date.fromTZDateTime(dt));

  Date get startDate => Date.fromTZDateTime(_interval.start);

  Date get endDate => Date.fromTZDateTime(_interval.end).subtract(1);

  Interval get interval => _interval;

  bool isOneDay() {
    return interval.end.difference(interval.start).inDays == 1;
  }
  bool isDayRange() {
//    var _isOneDay = isOneDay();
//    var _isOneMonth = isOneMonth();
//    var _isMonthRange = isMonthRange();
    return !isOneDay() && !isOneMonth() && !isMonthRange();
  }
  bool isOneMonth() {
    var mStart = Month.fromTZDateTime(interval.start);
    var mEnd = Month.fromTZDateTime(interval.end);
    return isBeginningOfMonth(interval.start) && isBeginningOfMonth(interval.start) && mStart == mEnd.previous;
  }
  bool isMonthRange() {
    var mStart = Month.fromTZDateTime(interval.start);
    var mEnd = Month.fromTZDateTime(interval.end);
    return isBeginningOfMonth(interval.start) && isBeginningOfMonth(interval.end) && mStart != mEnd.previous;
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! Term) return false;
    Term term = other;
    return _interval == term._interval;
  }

  @override
  int get hashCode => _interval.hashCode;

  @override
  String toString() => prettyTerm(_interval);
}

var _fmt = DateFormat('dMMMyy');

/// A convenience function to go from an interval to a String.  The output
/// doesn't contain the tz information anymore.
///
/// Works only for one day, day ranges, one month, and month ranges.
///
String prettyTerm(Interval interval) {
  var nDays = interval.end.difference(interval.start).inDays;
  var start = Date.fromTZDateTime(interval.start);
  if (nDays == 1) return start.toString(_fmt);

  if (isBeginningOfMonth(interval.start) && isBeginningOfMonth(interval.end)) {
    var mStart = Month.fromTZDateTime(interval.start);
    var mEnd = Month.fromTZDateTime(interval.end);
    if (mStart == mEnd.previous) {
      // it's exactly one month
      return mStart.toString();
    } else {
      // it's a month range
      return '${mStart.toString()}-${mEnd.previous.toString()}';
    }
  } else {
    // it's a day range
    var end = Date.fromTZDateTime(interval.end).previous;
    return '${start.toString(_fmt)}-${end.toString(_fmt)}';
  }
}
