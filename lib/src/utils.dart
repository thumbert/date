library utils;

import 'hour.dart';
import 'interval.dart';

/// Given a list of intervals return another list of contiguous intervals.
/// For example hours Hour.beginning(2017,1,1,1) and Hour.beginning(2017,1,1,2)
/// will combine into Interval [2017-01-01 01:00:00 -> 2017-01-01 03:00:00)
/// The input interval [x] needs to be sorted.
List<Interval> makeContiguousIntervals(List<Interval> x) {
  List res = [];
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


/// Split this interval into hours.
/// If the interval is inside an hour, return an empty list.
/// If the interval is exactly an hour, return it.
/// If the interval crosses the start of an hour, return both hours.
List<Hour> splitIntoHours(Interval interval) {
  List<Hour> res = [];
  Hour current = new Hour.containing(interval.start);
  Hour last;
  if (isBeginningOfHour(interval.end))
    last = new Hour.ending(interval.end);
  else
    last = new Hour.containing(interval.end);
  if (current == last) {
    if (isBeginningOfHour(interval.start) && isBeginningOfHour(interval.end))
      res.add(current);
  } else {
    while (!current.isAfter(last)) {
      res.add(current);
      current = current.next;
    }
  }
  return res;
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

