library time_ordering;

abstract class TimeOrdering<E> {
  bool isBefore(E that);
  bool isAfter(E that);
}

abstract class Additive<E> {
  E add(int i);
}

/// Just a union so I can extend it
abstract class ComparableWithAdd<E> extends Comparable<E> {
  E add(int i);
}
