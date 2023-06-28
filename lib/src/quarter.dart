library quarter;

import 'package:date/date.dart';
import 'package:date/src/time_ordering.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

class Quarter extends Interval implements TimeOrdering<Quarter> {
  int year;
  late int quarter;

  late int _value;
  static final isoFormat = DateFormat('yyyy-QQQ');
  static final format = DateFormat('QQQ, yyyy');
  static final format2 = DateFormat('QQQ, yy');

  /// There is no ISO standard
  Quarter(this.year, this.quarter, {required location})
      : super(TZDateTime.utc(year), TZDateTime.utc(year)) {
    _value = 100 * year + (quarter - 1) * 25;
    start = TZDateTime(location, year, (quarter - 1) * 3 + 1);
    end = Month.contains(start).add(2).end;
  }

  Quarter.fromTZDateTime(TZDateTime datetime)
      : year = datetime.year,
        super(TZDateTime(datetime.location, datetime.year),
            TZDateTime(datetime.location, datetime.year)) {
    var month = datetime.month;
    quarter = month ~/ 3 + 1;
    _value = 100 * year + (quarter - 1) * 25;
    start = TZDateTime(datetime.location, year, (quarter - 1) * 3 + 1);
    end = Month.contains(start).add(2).end;
  }

  Quarter.utc(this.year, this.quarter)
      : super(TZDateTime.utc(year), TZDateTime.utc(year)) {
    _value = 100 * year + (quarter - 1) * 25;
    start = TZDateTime.utc(year, (quarter - 1) * 3 + 1);
    end = Month.contains(start).add(2).end;
  }

  /// Parse the "ISO" format yyyy-Qq, yyyyQq or the readable format Qq, yyyy
  static Quarter parse(String x, Location location) {
    var year = int.parse(x.substring(0, 4));
    var offset = 0;
    if (x[4] == '-') offset += 1;
    var quarter = int.parse(x.substring(5 + offset));
    return Quarter(year, quarter, location: location);
  }

  Location get location => start.location;

  Date get startDate =>
      Date(start.year, start.month, start.day, location: location);

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
  String toString({DateFormat? fmt}) {
    fmt ??= isoFormat;
    return fmt.format(start);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! Quarter) return false;
    var quarter = other;
    return _value == quarter._value && location == quarter.location;
  }

  @override
  int get hashCode => _value;

  Interval toInterval() => Interval(start, end);
}
