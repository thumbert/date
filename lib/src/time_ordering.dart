library time_ordering;

abstract class TimeOrdering<E> {
  bool isBefore(E that);
  bool isAfter(E that);
}