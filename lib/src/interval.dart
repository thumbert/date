library interval;

/// An implementation of a time interval. The interval is ClosedOpen [start, end).
class Interval {
  DateTime _start;
  DateTime _end;

  Interval(DateTime start, DateTime end) {
    _start = start;
    _end = end;
    if (end.isBefore(start))
      throw new ArgumentError('Start DateTime needs to be before end DateTime.');
  }

  DateTime get start => _start;
  DateTime get end => _end;

  /// Does this interval abut with the other interval?
  bool abuts(Interval other) {
    bool res = false;
    if (end == other.start || start == other.end) {
      res = true;
    }
    return res;
  }

  /// Tests whether this interval contains this Datetime.
  bool containsTime(DateTime time) {
    if (start.isBefore(time) && end.isAfter(time)) return true;
    else if (time.isAtSameMomentAs(start)) return true;
    else return false;
  }

  /// Tests whether this interval has an overlapping part with this interval.
  bool hasOverlap(Interval other) {
    if ((end.isAfter(other.start)) || (other.end.isAfter(this.start))) return true;
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

  bool operator ==(Interval other) => other != null && _start == other.start
      && _end == other.end;

  int get hashCode => _start.hashCode;  /// TODO: FIXME!!

  String toString() => '[$_start, $end)';
}

