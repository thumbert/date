library term;

import 'package:date/date.dart';
import 'package:intl/intl.dart';
import 'package:petitparser/core.dart';
import 'package:timezone/timezone.dart';

class Term {
  /// A simple interval for a period between two dates, end date inclusive.
  Term(Date start, Date end) {
    _interval = Interval(start.start, end.end);
  }

  late Interval _interval;


  /// Throws a [ParserException] if parsing fails.
  ///
  Term.parse(String x, Location location) {
    _interval = parseTerm(x, tzLocation: location)!;
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

  /// Generate a list of terms.
  /// For example:
  /// <p>If years = [2021, 2022, 2023], return
  ///   ['Jan21-Dec21', 'Jan22-Dec22', 'Jan23-Dec23']
  ///
  /// <p>If years = [2021, 2022, 2023], monthRange = (12,3), return
  ///   ['Dec21-Mar22', 'Dec22-Mar23', 'Dec23-Mar24']
  ///
  /// <p>If years = [2021, 2022, 2023], monthRange = (12,3),  dayRange = (5,12)
  ///   return ['5Dec21-12Mar22', '5Dec22-12Mar23', '5Dec23-12Mar24']
  ///
  static List<Term> generate({required List<int> years, (int,int)? monthRange,
      (int,int)? dayRange, required Location location}) {
    var out = <Term>[];
    for (var year in years) {
      Date start, end;
      if (monthRange == null) {
        start = Date(year, 1, 1, location: location);
        end = Date(year, 12, 31, location: location);
      } else {
        if (dayRange == null) {
          start = Date(year, monthRange.$1, 1, location: location);
          if (monthRange.$2 >= monthRange.$1) {
            var monthEnd = Month(year, monthRange.$2, location: location);
            end = monthEnd.endDate;
          } else {
            var monthEnd = Month(year+1, monthRange.$2, location: location);
            end = monthEnd.endDate;
          }
        } else {
          start = Date(year, monthRange.$1, dayRange.$1, location: location);
          if (monthRange.$2 >= monthRange.$1) {
            end = Date(year, monthRange.$2, dayRange.$2, location: location);
          } else {
            end = Date(year+1, monthRange.$2, dayRange.$2, location: location);
          }
        }
      }
      out.add(Term(start, end));
    }

    return out;
  }

  Location get location => interval.start.location;

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
    late Date newEnd;
    if (interval.end == TZDateTime(location, _start.year, 3)) {
      newEnd = Date(year + offset, 3, 1, location: location).previous;
    } else {
      newEnd = Date(year + offset, _end.month, _end.day, location: location);
    }
    return Term(newStart, newEnd);
  }

  List<Date> days() => _interval.splitLeft((dt) => Date.containing(dt));

  List<Hour> hours() => _interval.splitLeft((dt) => Hour.beginning(dt));

  Date get startDate => Date.containing(_interval.start);

  Date get endDate => Date.containing(_interval.end).subtract(1);

  Interval get interval => _interval;

  bool isOneDay() {
    return interval.end.difference(interval.start).inDays == 1;
  }

  bool isDayRange() {
    return !isOneDay() && !isOneMonth() && !isMonthRange();
  }

  bool isOneMonth() {
    var mStart = Month.containing(interval.start);
    var mEnd = Month.containing(interval.end);
    return isBeginningOfMonth(interval.start) &&
        isBeginningOfMonth(interval.start) &&
        mStart == mEnd.previous;
  }

  bool isMonthRange() {
    var mStart = Month.containing(interval.start);
    var mEnd = Month.containing(interval.end);
    return isBeginningOfMonth(interval.start) &&
        isBeginningOfMonth(interval.end) &&
        mStart != mEnd.previous;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Term) return false;
    var term = other;
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
  var start = Date.containing(interval.start);
  if (nDays == 1) return start.toString(_fmt);

  if (interval.start.isBeginningOfMonth() && interval.end.isBeginningOfMonth()) {
    var mStart = Month.containing(interval.start);
    var mEnd = Month.containing(interval.end).previous;
    if (mStart == mEnd) {
      // it's exactly one month
      return mStart.toString();
    } else {
      // it's a month range.  Special treatment for Cal and Quarters
      if (mStart.month == 1 && mEnd.month == 12 && mEnd.year == mStart.year) {
        return 'Cal ${mStart.year % 100}';
      } else if (interval.isQuarter()) {
        return Quarter.fromTZDateTime(interval.start).toString(fmt: Quarter.format2);
      }
      return '${mStart.toString()}-${mEnd.toString()}';
    }
  } else {
    // it's a day range
    var end = Date.containing(interval.end).previous;
    return '${start.toString(_fmt)}-${end.toString(_fmt)}';
  }
}
