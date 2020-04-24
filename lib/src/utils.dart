library utils;

import 'interval.dart';

const _days = <List<int>>[
  [0,31,59,90,120,151,181,212,243,273,304,334],  // common year
  [0,31,60,91,121,152,182,213,244,274,305,335],  // leap year
];

/// Calculate the ordinal day of the year DDD, 1-365 or 366
int dayOfYear(int year, int month, int day) {
  if (year % 4 == 0) {
    // leap year
    return _days[1][month-1] + day;
  } else {
    return _days[0][month-1] + day;
  }
}


/// Given a list of intervals return another list of contiguous intervals.
/// For example hours Hour.beginning(2017,1,1,1) and Hour.beginning(2017,1,1,2)
/// will combine into Interval [2017-01-01 01:00:00 -> 2017-01-01 03:00:00)
/// The input intervals [x] needs to be sorted.
List<Interval> makeContiguousIntervals(List<Interval> x) {
  var res = <Interval>[];
  if (x.isEmpty) return [];
  var current = x.first;
  for (var i = 1; i < x.length; i++) {
    if (x[i].abuts(current)) {
      current = Interval(current.start, x[i].end);
    } else {
      res.add(current);
      current = x[i];
    }
  }
  res.add(current);
  return res;
}

/// Check if a DateTime is a beginning of an hour
bool isBeginningOfHour(DateTime dt) {
  if (dt.millisecondsSinceEpoch/1000 % 3600 !=0) {
    return false;
  }
  return true;
}


/// Check if a DateTime is beginning of a day.
bool isBeginningOfDay(DateTime dt) {
  if (dt.hour !=0 || !isBeginningOfHour(dt)) {
    return false;
  }
  return true;
}

bool isMidnight(DateTime dt) => isBeginningOfDay(dt);

/// Check if a DateTime is beginning of a week.
bool isBeginningOfWeek(DateTime dt) {
  if (dt.weekday != 1 || !isBeginningOfDay(dt) ) {
    return false;
  }
  return true;
}


/// Check if a DateTime is beginning of a month.
bool isBeginningOfMonth(DateTime dt) {
  if (dt.day != 1 || !isBeginningOfDay(dt) ) {
    return false;
  }
  return true;
}


/// Check if a DateTime is beginning of the year.
bool isBeginningOfYear(DateTime dt) {
  if (dt.month !=1 || !isBeginningOfMonth(dt)) {
    return false;
  }
  return true;
}

