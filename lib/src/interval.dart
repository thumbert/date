library interval;

import 'package:timezone/timezone.dart';

class Interval {
  TZDateTime _start;
  TZDateTime _end;

  /// An implementation of a time interval. The interval is ClosedOpen [start, end).
  Interval(TZDateTime start, TZDateTime end) {
    _start = start;
    _end = end;
    if (end.isBefore(start))
      throw new ArgumentError(
          'Start DateTime needs to be before end DateTime.');
  }

  /// Construct an interval of a given [duration] starting at a [start] TZDateTime.
  Interval.beginning(TZDateTime start, Duration duration) {
    _start = start;
    _end = start.add(duration);
  }

  /// Construct an interval of a given [duration] ending at a [start] TZDateTime.
  Interval.ending(TZDateTime end, Duration duration) {
    _end = end;
    _start = end.subtract(duration);
  }

  TZDateTime get start => _start;
  TZDateTime get end => _end;

  /// Does this interval abut with the other interval?
  bool abuts(Interval other) {
    bool res = false;
    if (end == other.start || start == other.end) {
      res = true;
    }
    return res;
  }

  /// Tests whether this interval contains this Datetime.
  bool containsTime(TZDateTime time) {
    if (start.isBefore(time) && end.isAfter(time))
      return true;
    else if (time.isAtSameMomentAs(start))
      return true;
    else
      return false;
  }

  /// Tests whether this interval contains this interval.
  bool containsInterval(Interval interval) {
    if ((start.isBefore(interval.start) ||
            start.isAtSameMomentAs(interval.start)) &&
        (end.isAfter(interval.end) || end.isAtSameMomentAs(interval.end)))
      return true;
    return false;
  }

  /// Return the overlap between two intervals.  If there is no overlap, throw.
  Interval overlap(Interval other) {
    DateTime iStart;
    if (start.isBefore(other.start)) {
      iStart = other.start;
    } else {
      iStart = start;
    }
    DateTime iEnd;
    if (end.isAfter(other.end)) {
      iEnd = other.end;
    } else {
      iEnd = end;
    }
    return new Interval(iStart, iEnd);
  }

  bool isInstant() => start.isAtSameMomentAs(end);

  bool operator ==(dynamic other) {
    if (other is! Interval) return false;
    Interval interval = other;
    return _start == interval.start && _end == interval.end;
  }

  /// see the pairing function http://szudzik.com/ElegantPairing.pdf
  int get hashCode {
    int res = end.millisecondsSinceEpoch * (end.millisecondsSinceEpoch + 1) +
        start.millisecondsSinceEpoch;
    return res;
  }

  /// Split this interval into a list of abutting intervals according to
  /// function [f].  The function [f] operates on the start(left) of
  /// each interval.
  /// <p>For example to split an year into hours use
  /// f = (x) => new Hour.beginning(x)
  /// <p>or, to split a month into days use
  /// f = (x) => new Date(x.year, x.month, x.day)
  List<Interval> splitLeft(Interval Function(TZDateTime) f) {
    List<Interval> res = [];
    Interval current = f(start);
    while ((current.end.millisecondsSinceEpoch)
            .compareTo(end.millisecondsSinceEpoch) <
        1) {
      res.add(current);
      current = f(current.end);
    }
    return res;
  }

  String toString() => isInstant() ? start.toString() : '[$_start, $end)';
}
