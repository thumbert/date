library week;

import 'package:date/date.dart';
import 'package:date/src/time_ordering.dart';
import 'package:timezone/timezone.dart';
import 'interval.dart';

class Week extends Interval implements TimeOrdering<Week> {
  int year;
  int week;
  Location location;

  static final Duration _1W = Duration(days: 7);
  int _value;
  TZDateTime _start, _end;

  /// ISO 8601 week
  /// see https://en.wikipedia.org/wiki/ISO_8601#Week_dates
  Week(this.year, this.week, this.location)
      : super(TZDateTime(location, year), TZDateTime(location, year)) {
    _value = 100*year + week;
    location ??= UTC;
    _start = _weekStart(year, week, location);
    _end = _start.add(_1W);
  }

  Week.fromTZDateTime(TZDateTime datetime)
      : super(TZDateTime(datetime.location, datetime.year), TZDateTime(datetime.location, datetime.year)){
    year = datetime.year;
    location = datetime.location;
    week = weekOfYear(datetime);
    _value = 100*year + week;
    _start = _weekStart(year, week, location);
    _end = _start.add(_1W);
  }

  /// Parse the ISO format yyyy-Www or yyyyWww
  static Week parse(String x, Location location) {
    var year = int.parse(x.substring(0,4));
    var offset = 0;
    if (x[4] == '-') offset += 1;
    var week = int.parse(x.substring(5+offset));
    return Week(year, week, location);
  }

  @override
  TZDateTime get start => _start;
  @override
  TZDateTime get end => _end;

  Date get startDate => Date(_start.year, _start.month, _start.day, location: location);

  Week get next => Week.fromTZDateTime(_end);

  Week get previous => Week.fromTZDateTime(_start.subtract(_1W));

  /// Calculate which week of the year this instant belongs to.
  /// Return an [int] between 1 and 52 || 53 depending on the year.
  static int weekOfYear(TZDateTime dt) {
    var date = Date(dt.year, dt.month, dt.day, location: dt.location);
    var w1Start = _weekStart(dt.year, 1, dt.location);
    var w1Start2 = _weekStart(dt.year+1, 1, dt.location);
    if (!dt.isBefore(w1Start2)) w1Start = w1Start2;
    if (dt.isBefore(w1Start)) {
      // it's last week of the previous year
      w1Start = _weekStart(dt.year-1, 1, dt.location);
    }
    var start = Date.fromTZDateTime(w1Start);
    var diff = date.value - start.value;
    var week = diff ~/ 7 + 1;
    return week;
  }


  /// Return the start of week
  static TZDateTime _weekStart(int year, int week, Location location) {
    var boy = TZDateTime(location, year);
    if ([5,6,7].contains(boy.weekday)) {
      /// on Fri, Sat, Sun => it's on last week of the previous year
      week += 1;
    }
    var start = boy.subtract(Duration(days: boy.weekday-1));
    return start.add(Duration(days: 7*(week-1)));
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
    Week week = other;
    return _value == week._value && location == week.location;
  }

  @override
  int get hashCode => _value;

  Interval toInterval() => Interval(_start, _end);

}
