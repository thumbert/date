library date.hour;

import 'package:timezone/timezone.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/time_ordering.dart';
import 'package:date/src/interval.dart';

/// An immutable class to represent an hour.
class Hour extends Interval implements TimeOrdering<Hour>, Additive<Hour> {
  static final Duration _H1 = Duration(hours: 1);

  /// Create an hour containing a given [TZDateTime].
  /// At Fall DST transition, this constructor will return the first hour, e.g.
  /// the hour starting on 2022-11-06 01:00:00.000-0400.
  Hour.containing(TZDateTime dt)
      : super(
            TZDateTime(dt.location, dt.year, dt.month, dt.day, dt.hour),
            TZDateTime(dt.location, dt.year, dt.month, dt.day, dt.hour)
                .add(_H1));

  /// Create an hour beginning at a given [TZDateTime]
  Hour.beginning(TZDateTime start) : super(start, start.add(_H1));

  /// Create an hour ending at a given [TZDateTime]
  Hour.ending(TZDateTime end) : super(end.subtract(_H1), end);

  /// Get the previous hour.
  Hour get previous => Hour.ending(start);

  /// Get the next hour.
  Hour get next => Hour.beginning(end);

  /// Get the [Date] for this hour.
  Date get currentDate =>
      Date(start.year, start.month, start.day, location: start.location);

  /// Add a number of hours to this hour.
  @override
  Hour add(int step) => Hour.beginning(start.add(Duration(hours: step)));

  /// Subtract a number of hours from this hours.
  Hour subtract(int step) =>
      Hour.beginning(start.subtract(Duration(hours: step)));

  @override
  bool isBefore(Hour other) => start.isBefore(other.start);

  @override
  bool isAfter(Hour other) => start.isAfter(other.start);

  @override
  bool operator ==(Object other) {
    if (other is! Hour) return false;
    var hour = other;
    return start == hour.start;
  }

  @override
  int get hashCode => start.hashCode;

  @override
  String toString() => '[$start, $end)';

  /// return this hour as an Interval
  Interval toInterval() => Interval(start, end);
}
