library month;

import 'package:date/date.dart';
import 'package:intl/intl.dart';
import 'package:date/src/time_ordering.dart';
import 'package:timezone/timezone.dart';

/// Class representing a calendar Month implemented as an Interval.
class Month extends Interval implements TimeOrdering<Month>, Additive<Month> {
  late final int year;

  /// between Jan=1 to Dec=12
  late final int month;
  late int _value;

  static final DateFormat _defaultFmt = DateFormat('MMMyy');
  static final DateFormat _isoFmt = DateFormat('yyyy-MM');

  /// Return the current month.  If location is not specified, return it
  /// in [UTC] timezone.
  /// 2020
  static Month current({DateTime? datetime, Location? location}) {
    datetime ??= DateTime.now();
    location ??= UTC;
    return Month(datetime.year, datetime.month, location: location);
  }

  /// Creates a new [Month] object.  Months are [Interval]s.
  /// The default timezone is UTC.
  /// Specify the timezone for the month
  /// if you want to split/aggregate months.
  Month(this.year, this.month, {required location})
      : super(TZDateTime(location, year, month),
            TZDateTime(location, year, month + 1)) {
    _value = year * 12 + month;
  }

  /// A convenience constructor for utc months
  Month.utc(this.year, this.month)
      : super(TZDateTime(UTC, year, month), TZDateTime(UTC, year, month + 1)) {
    _value = year * 12 + month;
  }

  /// Return the month that contains the tz datetime [dt].
  Month.containing(TZDateTime dt)
      : super(TZDateTime(dt.location, dt.year, dt.month),
            TZDateTime(dt.location, dt.year, dt.month + 1)) {
    year = dt.year;
    month = dt.month;
    _value = year * 12 + month;
  }

  /// Parse a string into a Month in the UTC timezone.  The default format is 'MMMyy'.
  ///
  /// Throws a [ParserException] if parsing fails.
  ///
  static Month parse(String s,
      {@deprecated DateFormat? fmt, Location? location}) {
    return parseMonth(s, location: location);
  }

  @Deprecated('Use Month.containing')

  /// Creates a new Month object from a DateTime.  The Month will contain the [datetime].
  Month.fromTZDateTime(TZDateTime datetime)
      : year = datetime.year,
        month = datetime.month,
        super(TZDateTime(datetime.location, datetime.year, datetime.month),
            TZDateTime(datetime.location, datetime.year, datetime.month + 1)) {
    _value = datetime.year * 12 + datetime.month;
  }

  /// Parse strings in the yyyy-mm format only, e.g. '2020-03'.
  static Month fromIsoString(String x, {Location? location}) {
    return Month(int.parse(x.substring(0, 4)), int.parse(x.substring(5, 7)),
        location: location ?? UTC);
  }

  /// Given an integer input like 202205 return the Month(2022,5).
  static Month fromInt(int x, {Location? location}) {
    var month = x % 100;
    var year = x ~/ 100;
    return Month(year, month, location: location ?? UTC);
  }

  int _calcYear(int x) => (x - 1) ~/ 12;
  int _calcMonth(int x) => (x - 1) % 12 + 1;

  Location get location => start.location;

  /// Get the first day of the month.
  Date get startDate => Date(year, month, 1, location: location);

  /// Get the last day of the month.
  Date get endDate => next.startDate.subtract(1);

  Month get previous =>
      Month(_calcYear(_value - 1), _calcMonth(_value - 1), location: location);

  /// Return the previous [n] months ending on this month.
  List<Month> previousN(int n) {
    var out = <Month>[];
    for (var i = n; i > 0; i--) {
      out.add(subtract(i));
    }
    return out;
  }

  Month get next =>
      Month(_calcYear(_value + 1), _calcMonth(_value + 1), location: location);

  /// Return the next [n] months starting on this month.
  List<Month> nextN(int n) {
    var out = <Month>[];
    for (var i = 1; i <= n; i++) {
      out.add(add(i));
    }
    return out;
  }

  /// Return all months starting from this month up to [month] inclusive.
  /// If [month] is before [this] throw.
  List<Month> upTo(Month month) {
    if (month.isBefore(this)) {
      throw ArgumentError('Month $month is before $this');
    }
    var out = <Month>[];
    var nextM = this;
    while (!month.isBefore(nextM)) {
      out.add(nextM);
      nextM = nextM.add(1);
    }
    return out;
  }

  /// Get a list with all the Mondays in the month
  List<Date> mondays() {
    var out = <Date>[];
    var dow = startDate.weekday;
    if (dow == 1) {
      // month starts on a Monday
      out.add(startDate);
    } else {
      // add the first Monday
      out.add(startDate.add(8 - dow));
    }
    var end1 = endDate.add(1);
    var candidate = out.last.add(7);
    while (candidate.isBefore(end1)) {
      out.add(candidate);
      candidate = candidate.add(7);
    }
    return out;
  }

  @override
  Month add(int months) =>
      Month(_calcYear(_value + months), _calcMonth(_value + months),
          location: location);
  Month subtract(int months) =>
      Month(_calcYear(_value - months), _calcMonth(_value - months),
          location: location);

  @override
  bool isBefore(Month other) => _value < other._value;
  @override
  bool isAfter(Month other) => _value > other._value;
  @override
  bool operator ==(Object other) {
    if (other is! Month) return false;
    var month = other;
    return _value == month._value && location == month.location;
  }

  @override
  int get hashCode => _value;

  /// Days of the month as list.
  List<Date> days() => splitLeft((dt) => Date.containing(dt));

  /// Quickly get the number of days in this month
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// return 202404 for Apr24
  int toInt() => year*100 + month;

  /// Format a month.  The default format is MMMyy.
  @override
  String toString([DateFormat? fmt]) {
    fmt ??= _defaultFmt;
    return fmt.format(start);
  }

  /// Format a month using the yyyy-MM format.
  String toIso8601String() => _isoFmt.format(start);

  Interval toInterval() => Interval(start, end);

  Month withTimeZone(Location location) {
    return Month(year, month, location: location);
  }

  static const shortNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
}
