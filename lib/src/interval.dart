library interval;

import 'package:timezone/timezone.dart';

class Interval implements Comparable<Interval> {
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

  /// Find the smallest interval covering all the input intervals.
  static Interval covering(Iterable<Interval> xs) {
    if (xs.isEmpty) throw ArgumentError('Input list should not be empty!');
    var res = xs.first;
    if (xs.length == 1) return res;
    for (var x in xs.skip(1)) {
      if (x.start.isBefore(res.start)) res = Interval(x.start, res.end);
      if (x.end.isAfter(res.end)) res = Interval(res.start, x.end);
    }
    return res;
  }

  /// Fuse an iterable of intervals by coalescing adjacent intervals to get
  /// the smallest number of intervals possible.  Only fuse intervals that abut.
  /// Throw if any of the input intervals are overlapping.
  ///
  static List<Interval> fuse(Iterable<Interval> xs) {
    var input = xs.toList()..sort();
    if (input.length == 0) return <Interval>[];
    if (input.length == 1) return input.toList();
    var out = <Interval>[];
    var previous = input.first;
    for (var x in input.skip(1)) {
      if (x.start == previous.end) {
        // be an optimist
        previous = previous.withEnd(x.end);
      } else if (x.start.isAfter(previous.end)) {
        // need to start another fuse interval
        out.add(previous);
        previous = x;
      } else {
        throw ArgumentError('Intervals $previous and $x are overlapping');
      }
    }
    out.add(previous);
    return out;
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

  /// Calculate the difference (in the sense of sets) between this interval
  /// and an iterable of intervals.  The resulting list can contain one or
  /// multiple intervals.  If there is no overlap between this interval and
  /// any of the input [intervals], return the original interval.
  /// If there is perfect covering return an empty list.
  List<Interval> difference(Iterable<Interval> intervals) {
    var out = <Interval>[this];
    for (var interval in intervals) {
      var newOut = <Interval>[];
      for (var one in out) {
        newOut.addAll(one._difference1(interval));
      }
      out = List.from(newOut);
    }
    return out;
  }

  /// Return an empty list when there is no difference, that is when
  /// [other] overlaps [this].
  List<Interval> _difference1(Interval other) {
    var out = <Interval>[];
    if (other.containsInterval(this)) return out;
    if (this.containsInterval(other)) {
      // other interval inside
      out.add(Interval(start, other.start));
      out.add(Interval(other.end, end));
    } else if (this.overlap(other) == null) {
      // there is no overlap, totally distinct
      out.add(this);
    } else if (end.isAfter(other.start) && start.isBefore(other.start)) {
      // there is a left remainder
      out.add(Interval(start, other.start));
    } else if (start.isBefore(other.end) && end.isAfter(other.end)) {
      // there is a right remainder
      out.add(Interval(other.end, end));
    } else {
      throw ArgumentError('What difference? $this and $other');
    }

    return out;
  }

  /// Return the overlap between two intervals.  If there is no overlap,
  /// return [null].
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
    if (iEnd.isBefore(iStart)) return null;
    return Interval(iStart, iEnd);
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
  /// f = (x) => Date(x.year, x.month, x.day)
  List<K> splitLeft<K extends Interval>(K Function(TZDateTime) f) {
    var res = <K>[];
    var current = f(start);
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
