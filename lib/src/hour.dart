library date.hour;

import 'package:timezone/standalone.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/time_ordering.dart';
import 'package:date/src/interval.dart';

/// An immutable class to represent an hour.
class Hour extends Interval implements TimeOrdering<Hour>, ComparableWithAdd<Hour> {
  /// number of hours since origin in UTC timezone, hour beginning
  /// should explore if this is worth doing.
  ///int _value;

  static Duration _H1 = new Duration(hours: 1);

  /// Create an hour containing a given [TZDateTime]
  Hour.containing(TZDateTime dt) : super(new TZDateTime(dt.location, dt.year, dt.month, dt.day, dt.hour),
      new TZDateTime(dt.location, dt.year, dt.month, dt.day, dt.hour+1)) {}
  
  /// Create an hour beginning at a given [TZDateTime]
  Hour.beginning(TZDateTime start): super(start, start.add(_H1)) {
    //_value = (start.toUtc().millisecondsSinceEpoch/3600000).round();
  }

  /// Create an hour ending at a given [TZDateTime]
  Hour.ending(TZDateTime end): super(end.subtract(_H1), end) {
    //_value = (end.toUtc().millisecondsSinceEpoch/3600000).round()-1;
  }

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

  bool operator ==(dynamic other) {
    if (other is! Hour) return false;
    Hour hour = other;
    return start == hour.start;
  }

  int compareTo(Hour other) => this.start.compareTo(other.start);

  int get hashCode => start.hashCode;

  String toString() => '[$start, $end)';

  /// return this hour as an Interval
  Interval toInterval() => new Interval(start, end);
}

