library utils;

import 'hour.dart';
import 'interval.dart';

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

