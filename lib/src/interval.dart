library interval;

import 'package:date/date.dart';
import 'package:timezone/timezone.dart';

class Interval implements Comparable<Interval> {
  late TZDateTime start;
  late TZDateTime end;

  /// An implementation of a time interval. The interval is ClosedOpen [start, end).
  /// The [start] and the [end] should be in the same time zone location.
  Interval(this.start, this.end) {
    if (end.isBefore(start)) {
      throw ArgumentError('Start is not before the end DateTime.');
    }
    if (start.location != end.location) {
      throw ArgumentError('Start and end need to be in the same timezone');
    }
  }

  /// Construct an interval of a given [duration] starting at a [start] TZDateTime.
  Interval.beginning(this.start, Duration duration) {
    end = start.add(duration);
  }

  /// Construct an interval of a given [duration] ending at a [start] TZDateTime.
  Interval.ending(this.end, Duration duration) {
    start = end.subtract(duration);
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
    if (xs.isEmpty) return <Interval>[];
    if (xs.length == 1) return xs.toList();
    var input = xs.toList()..sort();
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

  /// Calculate the union of intervals in a set sense.  It is different than
  /// [fuse] in that the input intervals [xs] can be overlapping and not sorted.
  /// The returning list contains sorted non-overlapping intervals.
  static List<Interval> union(List<Interval> xs) {
    if (xs.isEmpty) return <Interval>[];
    if (xs.length == 1) return xs.toList();
    xs.sort();
    var us = <Interval>[xs.first];
    for (var x in xs.skip(1)) {
      var last = us.last;
      if (x.start.isAfter(last.end)) {
        // disjoint
        us.add(x);
      } else {
        if (x.end.isAfter(last.end)) {
          us.last = Interval(last.start, x.end);
        }
      }
    }

    return us;
  }

  // TZDateTime get start => _start;
  // TZDateTime get end => _end;

  /// Does this interval abut with the other interval?
  bool abuts(Interval other) => start == other.end || end == other.start;

  /// Tests whether this interval contains this Datetime.
  bool containsTime(TZDateTime time) {
    if (start.isBefore(time) && end.isAfter(time)) {
      return true;
    } else if (time.isAtSameMomentAs(start)) {
      return true;
    } else {
      return false;
    }
  }

  /// Tests whether this interval contains this interval.
  bool containsInterval(Interval interval) {
    if ((start.isBefore(interval.start) ||
            start.isAtSameMomentAs(interval.start)) &&
        (end.isAfter(interval.end) || end.isAtSameMomentAs(interval.end))) {
      return true;
    }
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
    if (containsInterval(other)) {
      // other interval inside
      out.add(Interval(start, other.start));
      out.add(Interval(other.end, end));
    } else if (overlap(other) == null) {
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
  /// or if the two intervals are adjoining, return [null].
  Interval? overlap(Interval other) {
    TZDateTime iStart;
    if (start.isBefore(other.start)) {
      iStart = other.start;
    } else {
      iStart = start;
    }
    TZDateTime iEnd;
    if (end.isAfter(other.end)) {
      iEnd = other.end;
    } else {
      iEnd = end;
    }
    if (iEnd.isBefore(iStart) || abuts(other)) return null;
    return Interval(iStart, iEnd);
  }

  /// Split an interval at a given [TZDateTime]
  (Interval? left, Interval? right) splitAt(TZDateTime at) {
    assert(start.location == at.location);
    if (at.isBefore(start)) {
      return (null, this);
    } else if (at.isAfter(end) || at.isAtSameMomentAs(end)) {
      return (this, null);
    } else {
      return (Interval(start, at), Interval(at, end));
    }
  }

  bool isInstant() => start.isAtSameMomentAs(end);

  bool isQuarter() {
    if (start.isMidnight() && end.isMidnight()) {
      if (start.month == 1 && end.month == 4 && start.year == end.year) {
        return true;
      } else if (start.month == 4 && end.month == 7 && start.year == end.year) {
        return true;
      } else if (start.month == 7 &&
          end.month == 10 &&
          start.year == end.year) {
        return true;
      } else if (start.month == 10 &&
          end.month == 1 &&
          start.year == end.year - 1) {
        return true;
      }
    }
    return false;
  }

  bool isYear(Interval interval) {
    if (start.isBeginningOfYear() &&
        end.isBeginningOfYear() &&
        start.year == end.year - 1) {
      return true;
    }
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Interval) return false;
    var interval = other;
    return start == interval.start && end == interval.end;
  }

  /// Sort by start, if the start is identical, sort by end.
  @override
  int compareTo(Interval other) {
    var rS = start.compareTo(other.start);
    if (rS != 0) return rS;
    return end.compareTo(other.end);
  }

  /// see the pairing function http://szudzik.com/ElegantPairing.pdf
  @override
  int get hashCode {
    var res = end.millisecondsSinceEpoch * (end.millisecondsSinceEpoch + 1) +
        start.millisecondsSinceEpoch;
    return res;
  }

  Iterator<Hour> get hourIterator => _HourIterator(start, end);

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
    // NOTE: the calculation of milliseconds is expensive.  May want to think
    // of alternatives for a hot path.
    while ((current.end.millisecondsSinceEpoch)
            .compareTo(end.millisecondsSinceEpoch) <
        1) {
      res.add(current);
      current = f(current.end);
    }
    return res;
  }

  @override
  String toString() => isInstant() ? start.toString() : '[$start, $end)';

  /// Create a new interval ending with the specified end instant.
  /// If [end] is not specified, it means now.
  Interval withEnd([TZDateTime? end]) {
    end ??= TZDateTime.now(this.end.location);
    return Interval(start, end);
  }

  /// Create a new interval with the specified start instant.
  /// If [start] is not specified, it means now.
  Interval withStart([TZDateTime? start]) {
    start ??= TZDateTime.now(this.start.location);
    return Interval(start, end);
  }

  /// Create a new interval in the specified time zone.  Useful when you just
  /// want to change the time zone location.
  Interval withTimeZone(Location location) {
    var newStart = TZDateTime(
        location,
        start.year,
        start.month,
        start.day,
        start.hour,
        start.minute,
        start.second,
        start.millisecond,
        start.microsecond);
    var newEnd = TZDateTime(location, end.year, end.month, end.day, end.hour,
        end.minute, end.second, end.millisecond, end.microsecond);
    return Interval(newStart, newEnd);
  }
}

class _HourIterator implements Iterator<Hour> {
  TZDateTime start, end;
  TZDateTime? _current;
  static const h1 = Duration(hours: 1);

  _HourIterator(this.start, this.end) {
    if (!start.isBeginningOfHour()) {
      throw ArgumentError('Start should be at hour beginning, it is $start');
    }
    if (end.difference(start).inHours < 1) {
      throw ArgumentError('Sub hourly interval.  Nothing to iterate.');
    }
  }

  @override
  bool moveNext() {
    if (_current == null) {
      _current = start;
      return true;
    } else {
      var candidate = _current!.add(h1);
      var res = candidate.isBefore(end);
      if (res) {
        _current = candidate;
      }
      return res;
    }
  }

  @override
  Hour get current => Hour.beginning(_current!);
}
