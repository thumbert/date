library date.hour;

import 'package:timezone/standalone.dart';
import 'package:date/src/date_base.dart';

/// An immutable class to represent an hour.
class Hour extends Comparable<Hour> {
  TZDateTime _start, _end;

  static Duration _H1 = new Duration(hours: 1);

  /// Create an hour beginning at a given [TZDateTime]
  Hour.beginning(TZDateTime start) {
    _start = start;
    _end = start.add(_H1);
  }

  /// Create an hour ending at a given [TZDateTime]
  Hour.ending(TZDateTime end) {
    _start = end.subtract(_H1);
    _end = end;
  }

  TZDateTime get start => _start;
  TZDateTime get end => _end;

  /**
   * Return the previous hour.
   */
  Hour get previous => new Hour.ending(_start);

  /**
   * Return the next hour.
   */
  Hour get next => new Hour.beginning(_end);

  /// get the [Date] for this hour.
  Date get date => new Date(start.year, start.month, start.day);

  /**
   * Add a number of hours to this hour.
   */
  Hour add(int step) => new Hour.beginning(start.add(new Duration(hours: step)));

  /**
   * Subtract a number of hours from this hours.
   */
  Hour subtract(int step) => new Hour.beginning(start.subtract(new Duration(hours: step)));


  bool isBefore(Hour other) => _start.isBefore(other._start);

  bool isAfter(Hour other) => _start.isAfter(other._start);

  bool operator ==(Hour other) => other != null && _start == other._start;

  int compareTo(Hour other)    => this.start.compareTo(other.start);
  int get hashCode => _start.hashCode;


  String toString() => 'HB: $_start';

}

