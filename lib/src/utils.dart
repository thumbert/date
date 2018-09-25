library utils;

import 'interval.dart';

/// Given a list of intervals return another list of contiguous intervals.
/// For example hours Hour.beginning(2017,1,1,1) and Hour.beginning(2017,1,1,2)
/// will combine into Interval [2017-01-01 01:00:00 -> 2017-01-01 03:00:00)
/// The input intervals [x] needs to be sorted.
List<Interval> makeContiguousIntervals(List<Interval> x) {
  var res = <Interval>[];
  if (x.isEmpty) return [];
  Interval current = x.first;
  for (int i = 1; i < x.length; i++) {
    if (x[i].abuts(current)) {
      current = new Interval(current.start, x[i].end);
    } else {
      res.add(current);
      current = x[i];
    }
  }
  res.add(current);
  return res;
}

/// Get the next [n] days starting on Date [fromDate] (inclusive).
List<Date> getNextNDays(int n, Date fromDate) {
  var out = <Date>[];
  for (int i=0; i<n; i++) {
    out.add(fromDate.add(i));
  }
  return out;
}


/// Get the last [n] days ending on Date [fromDate] (inclusive).
List<Date> getLastNDays(int n, Date fromDate) {
  var out = <Date>[];
  for (int i=n-1; i>=0; i--) {
    out.add(fromDate.subtract(i));
  }
  return out;
}


/// Check if a DateTime is a beginning of an hour
bool isBeginningOfHour(DateTime dt) {
  if (dt.minute !=0 || dt.second !=0 || dt.millisecond !=0)
    return false;
  return true;
}

/// Check if a DateTime is beginning of a day.
bool isBeginningOfDay(DateTime dt) {
  if (dt.hour !=0 || !isBeginningOfHour(dt))
    return false;
  return true;
}

bool isMidnight(DateTime dt) => isBeginningOfDay(dt);


/// Check if a DateTime is beginning of a month.
bool isBeginningOfMonth(DateTime dt) {
  if (dt.day != 1 || !isBeginningOfDay(dt) )
    return false;
  return true;
}


/// Check if a DateTime is beginning of the year.
bool isBeginningOfYear(DateTime dt) {
  if (dt.month !=1 || !isBeginningOfMonth(dt))
    return false;
  return true;
}

