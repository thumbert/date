library week;

import 'package:date/date.dart';
import 'package:date/src/time_ordering.dart';
import 'package:timezone/timezone.dart';

class Week extends Interval implements TimeOrdering<Week> {
  int year;
  late int week;
  Location location;

  static final Duration _1W = Duration(days: 7);
  late int _value;

  /// ISO 8601 week
  /// see https://en.wikipedia.org/wiki/ISO_8601#Week_dates
  /// No check is made to make sure that the values for [week] are valid.
  /// So prefer the [Week.fromTZDateTime] constructor.
  Week(this.year, this.week, this.location)
      : super(TZDateTime(location, year), TZDateTime(location, year)) {
    _value = 100 * year + week;
    start = weekStart(year, week, location);
    end = Date.fromTZDateTime(start).add(7).start;
  }

  /// Implement https://en.wikipedia.org/wiki/ISO_week_date#Calculating_the_week_number_from_a_month_and_day_of_the_month_or_ordinal_date
  Week.fromTZDateTime(TZDateTime datetime)
      : year = datetime.year,
        location = datetime.location,
        super(TZDateTime(datetime.location, datetime.year),
            TZDateTime(datetime.location, datetime.year)) {
    var doy = dayOfYear(year, datetime.month, datetime.day);
    var res = (doy - datetime.weekday + 10) ~/ 7;
    if (res == 0) {
      // in previous year
      year -= 1;
      week = weekOfYear(datetime);
    } else if (res == 53) {
      // need to check if not in week 1 of following year
      week = weekOfYear(datetime);
      if (week == 1) year += 1;
    } else {
      week = res;
    }
    _value = 100 * year + week;
    start = weekStart(year, week, location);
    end = Date.fromTZDateTime(start).add(7).start;
  }

  /// Parse the ISO format yyyy-Www or yyyyWww
  static Week parse(String x, Location location) {
    var year = int.parse(x.substring(0, 4));
    var offset = 0;
    if (x[4] == '-') offset += 1;
    var week = int.parse(x.substring(5 + offset));
    return Week(year, week, location);
  }

  Date get startDate =>
      Date(start.year, start.month, start.day, location: location);

  Week get next => Week.fromTZDateTime(end);

  Week get previous => Week.fromTZDateTime(start.subtract(_1W));

  /// Calculate which week of the year this instant belongs to.
  /// Return an [int] between 1 and 52 || 53 depending on the year.
  static int weekOfYear(TZDateTime dt) {
    var date = Date(dt.year, dt.month, dt.day, location: dt.location);
    var w1Start = weekStart(dt.year, 1, dt.location);
    var w1Start2 = weekStart(dt.year + 1, 1, dt.location);
    if (!dt.isBefore(w1Start2)) w1Start = w1Start2;
    if (dt.isBefore(w1Start)) {
      // it's last week of the previous year
      w1Start = weekStart(dt.year - 1, 1, dt.location);
    }
    var start = Date.fromTZDateTime(w1Start);
    var diff = date.value - start.value;
    var week = diff ~/ 7 + 1;
    return week;
  }

  /// Return the start of week
  static TZDateTime weekStart(int year, int week, Location location) {
    // do the calculations in UTC, otherwise you get errors
    var boy = TZDateTime.utc(year);
    if ([5, 6, 7].contains(boy.weekday)) {
      /// on Fri, Sat, Sun => it's on last week of the previous year
      week += 1;
    }
    var _start = boy.subtract(Duration(days: boy.weekday - 1));
    _start = _start.add(Duration(days: 7 * (week - 1)));
    return TZDateTime(location, _start.year, _start.month, _start.day);
  }

  @override
  bool isAfter(Week that) => _value > that._value;

  @override
  bool isBefore(Week that) => _value < that._value;

  List<Date> days() => splitLeft((dt) => Date.fromTZDateTime(dt));

  @override
  String toString() {
    return '$year-W${week.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! Week) return false;
    var week = other;
    return _value == week._value && location == week.location;
  }

  @override
  int get hashCode => _value;

  Interval toInterval() => Interval(start, end);
}
