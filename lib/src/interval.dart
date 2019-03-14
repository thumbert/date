library interval;

import 'package:timezone/timezone.dart';

class Interval implements Comparable<Interval>{
  TZDateTime _start;
  TZDateTime _end;

  /// An implementation of a time interval. The interval is ClosedOpen [start, end).
  /// The [start] and the [end] should be in the same time zone location.
  Interval(TZDateTime start, TZDateTime end) {
    _start = start;
    _end = end;
    if (end.isBefore(start))
      throw ArgumentError('Start is not before the end DateTime.');
    if (start.location != end.location)
      throw ArgumentError('Start and end need to be in the same timezone');
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

  int compareTo(Interval other) {
    var rS = start.compareTo(other.start);
    if (rS != 0) return rS;
    return end.compareTo(other.end);
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

  /// Creates a new interval ending with the specified end instant.
  /// If [end] is not specified, it means now.
  Interval withEnd([TZDateTime end]) {
    end ??= TZDateTime.now(this.end.location);
    return Interval(start, end);
  }


  /// Creates a new interval with the specified start instant.
  /// If [start] is not specified, it means now.
  Interval withStart([TZDateTime start]) {
    start ??= TZDateTime.now(this.start.location);
    return Interval(start, end);
  }
}
