library month_ext;

import 'month.dart';

extension MonthIterableExtension on Iterable<Month> {
  /// Returns the earliest calendar month, retaining the first on a tie.
  ///
  /// Throws a [StateError] if the iterable is empty.
  Month min() => reduce((a, b) => b.isBefore(a) ? b : a);

  /// Returns the latest calendar month, retaining the first on a tie.
  ///
  /// Throws a [StateError] if the iterable is empty.
  Month max() => reduce((a, b) => b.isAfter(a) ? b : a);
}
