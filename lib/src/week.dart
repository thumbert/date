library week;

import 'package:date/date.dart';
import 'package:date/src/time_ordering.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'interval.dart';

class Week extends Interval implements TimeOrdering<Week> {
  final int year;
  final int week;
  Location location;
  static final Duration _1W = Duration(days: 7);
  num _value;
  TZDateTime _start, _end;

  /// ISO 8601 week
  /// see https://en.wikipedia.org/wiki/ISO_8601#Week_dates
  Week(this.year, this.week, this.location)
      : super(TZDateTime(location, year), TZDateTime(location, year)) {
    _value = year + week / 53;
    location ??= UTC;
    _start = _weekStart(year, week, location);
    _end = _start.add(_1W);
  }

//  Week.fromTZDateTime(TZDateTime datetime) {
//
//  }


  @override
  TZDateTime get start => _start;
  @override
  TZDateTime get end => _end;

  Date get startDate => Date(_start.year, _start.month, _start.day, location: location);

  /// Return the start of week
  static TZDateTime _weekStart(int year, int week, Location location) {
    var boy = TZDateTime(location, year);
    var start = boy.subtract(Duration(days: boy.weekday-1));
    if ([5,6,7].contains(boy.weekday)) {
      /// on Fri, Sat, Sun => it's on last week of the previous year
      week += 1;
    }
    return start.add(Duration(days: 7*(week-1)));
  }


  @override
  bool isAfter(Week that) {
    // TODO: implement isAfter
    return null;
  }

  @override
  bool isBefore(Week that) {
    // TODO: implement isBefore
    return null;
  }


  @override
  bool operator ==(dynamic other) {
    if (other is! Week) return false;
    Week week = other;
    return _value == week._value && location == week.location;
  }

  @override
  int get hashCode => _value;



}
