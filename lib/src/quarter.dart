library quarter;

import 'package:date/date.dart';
import 'package:date/src/time_ordering.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'interval.dart';

class Quarter extends Interval implements TimeOrdering<Quarter> {
  int year;
  int quarter;
  Location location;

  int _value;
  TZDateTime _start, _end;
  static final isoFormat = DateFormat('yyyy-QQQ');
  static final format = DateFormat('QQQ, yyyy');

  /// There is no ISO standard
  Quarter(this.year, this.quarter, {this.location})
      : super(TZDateTime.utc(year), TZDateTime.utc(year)) {
    _value = 100 * year + (quarter - 1) * 25;
    location ??= UTC;
    _start = TZDateTime(location, year, (quarter - 1) * 3 + 1);
    _end = Month.fromTZDateTime(_start).add(2).end;
  }

  Quarter.fromTZDateTime(TZDateTime datetime)
      : super(TZDateTime(datetime.location, datetime.year),
            TZDateTime(datetime.location, datetime.year)) {
    year = datetime.year;
    location = datetime.location;
    var month = datetime.month;
    quarter = month ~/ 3 + 1;

    _value = 100 * year + (quarter-1) * 25;
    _start = TZDateTime(location, year, (quarter - 1) * 3 + 1);
    _end = Month.fromTZDateTime(_start).add(2).end;
  }

  /// Parse the "ISO" format yyyy-Qq, yyyyQq or the readable format Qq, yyyy
  static Quarter parse(String x, Location location) {
    var year = int.parse(x.substring(0, 4));
    var offset = 0;
    if (x[4] == '-') offset += 1;
    var quarter = int.parse(x.substring(5 + offset));
    return Quarter(year, quarter, location: location);
  }

  @override
  TZDateTime get start => _start;
  @override
  TZDateTime get end => _end;

  Date get startDate =>
      Date(_start.year, _start.month, _start.day, location: location);

  Quarter get next => add(1);

  Quarter get previous => subtract(1);

  Quarter add(int quarters) {
    var newValue = _value + quarters * 25;
    var newYear = newValue ~/ 100;
    var newQuarter = (newValue - newYear * 100) ~/ 25 + 1;
    return Quarter(newYear, newQuarter, location: location);
  }

  Quarter subtract(int quarters) {
    var newValue = _value - quarters * 25;
    var newYear = newValue ~/ 100;
    var newQuarter = (newValue - newYear * 100) ~/ 25 + 1;
    return Quarter(newYear, newQuarter, location: location);
  }

  @override
  bool isAfter(Quarter that) => _value > that._value;

  @override
  bool isBefore(Quarter that) => _value < that._value;

  List<Date> days() => splitLeft((dt) => Date.fromTZDateTime(dt));

  @override
  String toString({DateFormat fmt}) {
    fmt ??= isoFormat;
    return fmt.format(start);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! Quarter) return false;
    Quarter quarter = other;
    return _value == quarter._value && location == quarter.location;
  }

  @override
  int get hashCode => _value;

  Interval toInterval() => Interval(_start, _end);
}
