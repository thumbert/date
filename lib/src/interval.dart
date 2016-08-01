library interval;

enum IntervalType {
  CloseOpen,
  CloseClose,
  OpenOpen,
  OpenClose
}

class Interval {
  DateTime _start;
  DateTime _end;
  IntervalType _type;

  Interval(DateTime start, DateTime end, {IntervalType type: IntervalType.CloseOpen}) {
    _start = start;
    _end = end;
    _type = type;
    if (end.isBefore(start))
      throw new ArgumentError('Start DateTime needs to be before end DateTime.');
    if (start == end && type == IntervalType.OpenOpen)
      throw new ArgumentError('An open-open interval for the same start and end does not exist');
  }

  DateTime get start => _start;
  DateTime get end => _end;
  IntervalType get type => _type;

  /// Does this interval abut with the other interval?
  bool abuts(Interval other) {
    bool res = false;
    if (end == other.start || start == other.end) {
      if ((isOpenEnd() && other.isClosedStart()) ||
          (isClosedEnd() && other.isOpenEnd()) ||
          (other.isOpenEnd() && isClosedStart()) ||
          (other.isClosedEnd() && isOpenStart())) res = true;
    }
    return res;
  }

  /// Tests whether this interval has an overlapping part with this interval.
  bool hasOverlap(Interval other) {
    if ((end.isAfter(other.start)) || (other.end.isAfter(this.start))) return true;
    return false;
  }

  /// Return the overlap between two intervals.  If there is no overlap, throw.
  Interval overlap(Interval other) {
    DateTime iStart;
    bool openFlagStart;
    if (start.isBefore(other.start)) {
      iStart = other.start;
      openFlagStart = other.isOpenStart();
    } else {
      iStart = start;
      openFlagStart = isOpenStart();
    }
    DateTime iEnd;
    bool openFlagEnd;
    if (end.isAfter(other.end)) {
      iEnd = other.end;
      openFlagEnd = other.isOpenEnd();
    } else {
      iEnd = end;
      openFlagEnd = isOpenEnd();
    }
    return new Interval(iStart, iEnd, type: _getType(openFlagStart, openFlagEnd));
  }

  /// Return the type of the interval from the individual end types.
  IntervalType _getType(bool openFlagStart, bool openFlagEnd) {
    if (openFlagStart) {
      if (openFlagEnd)
        return IntervalType.OpenOpen;
      else
        return IntervalType.OpenClose;
    } else {
      if (openFlagEnd)
        return IntervalType.CloseOpen;
      else
        return IntervalType.CloseClose;
    }
  }



  /// is the start of this interval open (...
  bool isOpenStart() => type == IntervalType.OpenClose || type == IntervalType.OpenOpen;
  /// is the end of this interval open ...)
  bool isOpenEnd() => type == IntervalType.CloseOpen || type == IntervalType.OpenOpen;
  /// is the start of this interval closed [...
  bool isClosedStart() => type == IntervalType.CloseOpen || type == IntervalType.CloseClose;
  /// is the end of this interval closed ...]
  bool isClosedEnd() => type == IntervalType.OpenClose || type == IntervalType.CloseClose;


  bool operator ==(Interval other) => other != null && _start == other.start
      && _end == other.end && _type == other.type;

  int get hashCode => _start.hashCode;

  String toString() {
    String out;
    switch (type) {
      case IntervalType.CloseClose:
        out = '[$_start, $end]';
        break;
      case IntervalType.CloseOpen:
        out = '[$_start, $end)';
        break;
      case IntervalType.OpenClose:
        out = '($_start, $end]';
        break;
      case IntervalType.OpenOpen:
        out = '($_start, $end)';
        break;
    }
    return out;
  }
}

