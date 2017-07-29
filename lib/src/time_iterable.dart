library time_iterable;

import 'dart:collection';
import 'package:date/src/date_base.dart';
import 'time_ordering.dart';

class TimeIterable<E extends ComparableWithAdd<E>> extends Object
    with IterableMixin<E> {
  E start;
  E end;
  int step;

  /// A generic iterable for the common date objects in this package.
  /// Can be used to get an iterable of [Date] objects,
  ///    [Month] objects, etc.
  ///    From [start] to [end] inclusive.
  ///    The [step] can be positive or negative (but non-zero.)
  ///
  TimeIterable(E this.start, E this.end, {int this.step: 1}) {
    if (end.compareTo(start) > 0 && step < 0)
      throw 'End is after start and step is negative!';
    if (end.compareTo(start) < 0 && step > 0)
      throw 'End is before start and step is positive!';
  }

  Iterator<E> get iterator => new TimeIterator<E>(start, end, step: step);
}

/// An iterator for time interval objects.  The type [E] needs to have an [add] method.
class TimeIterator<E extends ComparableWithAdd<E>> extends Iterator<E> {
  E _current, start, end;
  int step;
  Function _isDone;

  TimeIterator(E this.start, E this.end, {int this.step: 1}) {
    if (step > 0) {
      _isDone = (x) => x.compareTo(end) > 0;
    } else if (step < 0) {
      _isDone = (x) => x.compareTo(end) < 0;
    } else {
      throw 'Step cannot be zero.';
    }
  }

  bool moveNext() {
    bool res = true;
    if (_current == null) {
      _current = start;
    } else {
      _current = _current.add(step);
      if (_isDone(_current)) res = false;
    }

    return res;
  }

  E get current => _current;
}
