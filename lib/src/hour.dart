library date.hour;

import 'package:timezone/timezone.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/time_ordering.dart';
import 'package:date/src/interval.dart';

/// An immutable class to represent an hour.
class Hour extends Interval implements TimeOrdering<Hour>, Additive<Hour> {
  static final Duration _H1 = Duration(hours: 1);

  /// Create an hour containing a given [TZDateTime].
  /// At Fall DST transition this correctly returns the hour that actually
  /// contains [dt], including the repeated 01:xx EST hour.
  factory Hour.containing(TZDateTime dt) {
    final start = _truncateToHour(dt);
    return Hour.beginning(start);
  }

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

  /// Truncate [dt] to the start of its clock hour using epoch arithmetic,
  /// so that the correct DST occurrence is preserved.
  static TZDateTime _truncateToHour(TZDateTime dt) {
    final ms = dt.millisecondsSinceEpoch;
    return TZDateTime.fromMillisecondsSinceEpoch(
      dt.location,
      ms - ms % Duration.millisecondsPerHour,
    );
  }

}
