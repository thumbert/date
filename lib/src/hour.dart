library date.hour;

import 'package:timezone/standalone.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/time_ordering.dart';
import 'package:date/src/interval.dart';

/// An immutable class to represent an hour.
class Hour extends Interval with Comparable<Hour> implements TimeOrdering<Hour> {
  TZDateTime _start, _end;

  static Duration _H1 = new Duration(hours: 1);

  /// Create an hour beginning at a given [TZDateTime]
  Hour.beginning(TZDateTime start): super(start, start.add(_H1)) {
    _start = start;
  }

  /// Create an hour ending at a given [TZDateTime]
  Hour.ending(TZDateTime end): super(end.subtract(_H1), end) {
    _end = end;
  }

  TZDateTime get start => _start != null ? _start : end.subtract(_H1);
  TZDateTime get end => _end != null ? _end : start.add(_H1);

  /**
   * Get the previous hour.
   */
  Hour get previous => new Hour.ending(start);

  /**
   * Get the next hour.
   */
  Hour get next => new Hour.beginning(end);

  /// Get the [Date] for this hour.
  Date get currentDate => new Date(start.year, start.month, start.day);

  /**
   * Add a number of hours to this hour.
   */
  Hour add(int step) => new Hour.beginning(start.add(new Duration(hours: step)));

  /**
   * Subtract a number of hours from this hours.
   */
  Hour subtract(int step) => new Hour.beginning(start.subtract(new Duration(hours: step)));

  bool isBefore(Hour other) => start.isBefore(other.start);

  bool isAfter(Hour other) => start.isAfter(other.start);

  bool operator ==(Hour other) => other != null && start == other.start;

  int compareTo(Hour other) => this.start.compareTo(other.start);

  int get hashCode => _start.hashCode;

  String toString() => '[$start, $end)';

  /// return this hour as an Interval
  Interval toInterval() => new Interval(start, end);
}

