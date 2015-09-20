library time_iterable;

import'dart:collection';
import 'package:date/src/date_base.dart';


/**
 * A generic iterable for the common date objects in this package.
 * Can be used to get an iterable of [Date] objects,
 * [Month] objects, etc.
 *
 */
class TimeIterable<E extends Comparable<E>> extends Object with IterableMixin<E> {
  E start;
  E end;
  int step;

  TimeIterable({E this.start, E this.end, int this.step:1});

  Iterator<E> get iterator => new TimeIterator<E>(start, end, step: step);
}

/**
 * An iterator for date objects.  The type [E] needs to have an [add] method.
 */
class TimeIterator<E extends Comparable<E>> extends Iterator<E> {
  E _current, start, end;
  int step;

  TimeIterator(E this.start, E this.end, {int this.step: 1});

  bool moveNext() {
    bool res = true;
    if (_current == null) {
      _current = start;
    } else {
      _current = _current.add(step);
      if (_current.compareTo(end) < 0) res = false;
    }

    return res;
  }

  E get current => _current;
}
