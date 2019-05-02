library term_parse;

import 'package:intl/intl.dart';
import 'package:petitparser/petitparser.dart';
import 'package:date/date.dart';
import 'package:timezone/timezone.dart';

final TermParser _parser = TermParser();

// Decided not to support the ISO8601 duration parser.

/// Parse a limited number of String inputs into a datetime interval.
/// Supported tokens are:
/// <p>days: 1Jan17, months: 'Jan17', 'F18', years: 'Cal17', quarters: 'Q3,18',
/// day ranges: 1Jan17-3Jan17, or month ranges: Jul17-Aug17.
///
/// <p>Or a term relative to the current moment.  For example:
/// '-10d' the last 10 days, '+10d' the next 10 days,
/// '-3m' represents approximately the last three months,
/// '-2y', represents approximately the last 2 years.
///
/// <p>If the tzLocation is not specified, return the interval in UTC timezone,
/// otherwise, return the interval in the time zone specified.
/// Throws an [ArgumentError] if the parsing fails.
Interval parseTerm(String term, {Location tzLocation}) {
  var res = _parser.parse(term);
  if (res.isFailure) throw ArgumentError('Couldn\'t parse term $term.');
  var interval = res.value as Interval;
  if (tzLocation != null) {
    var start = interval.start;
    var end = interval.end;
    interval = Interval(
        TZDateTime(tzLocation, start.year, start.month, start.day),
        TZDateTime(tzLocation, end.year, end.month, end.day));
  }
  return interval;
}

/// A convenience function to go from an interval to a String.  The output
/// doesn't contain the tz information anymore.
///
/// Works only for one day, day ranges, one month, and month ranges.
///
String prettyTerm(Interval interval) {
  if (!isMidnight(interval.start))
    throw ArgumentError('Interval start needs to be at midnight');
  if (!isMidnight(interval.end))
    throw ArgumentError('Interval end needs to be at midnight');

  var fmt = DateFormat("dMMMyy");
  var nDays = interval.end.difference(interval.start).inDays;
  var start = Date.fromTZDateTime(interval.start);
  if (nDays == 1) return start.toString(fmt);

  if (isBeginningOfMonth(interval.start) && isBeginningOfMonth(interval.end)) {
    var mStart = Month.fromTZDateTime(interval.start);
    var mEnd = Month.fromTZDateTime(interval.end);
    if (mStart == mEnd.previous) {
      // it's exactly one month
      return mStart.toString();
    } else {
      // it's a month range
      return '${mStart.toString()}-${mEnd.previous.toString()}';
    }
  } else {
    // it's a day range
    var end = Date.fromTZDateTime(interval.end).previous;
    return '${start.toString(fmt)}-${end.toString(fmt)}';
  }
}

class TermGrammar extends GrammarParser {
  TermGrammar() : super(const TermGrammarDefinition());
}

class TermGrammarDefinition extends GrammarDefinition {
  const TermGrammarDefinition();

  start() => ref(value).end();
  token(Parser p) => p.flatten().trim();
  simpleDayToken() => ref(dayToken) & ref(monthToken) & ref(yearToken);
  simpleMonthToken() => ref(monthToken) & ref(yearToken);
  simpleMonthCodeToken() => token(letter() & digit() & digit());
  simpleQuarterToken() => quarterToken();
  simpleCalYearToken() => calYearToken();
  simpleToken() =>
      simpleCalYearToken() |
      ref(simpleMonthToken) |
      ref(simpleMonthCodeToken) |
      ref(simpleDayToken) |
      simpleQuarterToken();

  compoundDayToken() => ref(simpleDayToken) & char('-') & ref(simpleDayToken);
  compoundMonthToken() =>
      ref(simpleMonthToken) & char('-') & ref(simpleMonthToken);
  compoundToken() => compoundMonthToken() | compoundDayToken();

  relativeToken() => token(char('-') | char('+')) & digit().plus() & letter();

  // compound term needs to be parsed first
  value() => ref(compoundToken) | ref(simpleToken) | ref(relativeToken);

  dayToken() => token(digit().repeat(1, 2));
  monthToken() =>
      jan() |
      feb() |
      mar() |
      apr() |
      may() |
      jun() |
      jul() |
      aug() |
      sep() |
      oct() |
      nov() |
      dec();
  yearToken() => token(digit().repeat(2, 4));
  quarterToken() => token(char('Q') & digit()) & char(',') & yearToken();
  calYearToken() => token((string('CAL') | string('Cal'))) & yearToken();

  jan() => token(string('January') |
      string('JANUARY') |
      string('Jan') |
      string('JAN') |
      string('jan'));
  feb() => token(string('February') |
      string('FEBRUARY') |
      string('feb') |
      string('Feb') |
      string('FEB'));
  mar() => token(string('March') |
      string('MARCH') |
      string('mar') |
      string('Mar') |
      string('MAR'));
  apr() => token(string('April') |
      string('APRIL') |
      string('apr') |
      string('Apr') |
      string('APR'));
  may() => token(string('May') | string('MAY') | string('may'));
  jun() => token(string('June') |
      string('JUNE') |
      string('jun') |
      string('Jun') |
      string('JUN'));
  jul() => token(string('July') |
      string('JULY') |
      string('jul') |
      string('Jul') |
      string('JUL'));
  aug() => token(string('August') |
      string('AUGUST') |
      string('aug') |
      string('Aug') |
      string('AUG'));
  sep() => token(string('September') |
      string('SEPTEMBER') |
      string('sep') |
      string('Sep') |
      string('SEP'));
  oct() => token(string('October') |
      string('OCTOBER') |
      string('oct') |
      string('Oct') |
      string('OCT'));
  nov() => token(string('November') |
      string('NOVEMBER') |
      string('nov') |
      string('Nov') |
      string('NOV'));
  dec() => token(string('December') |
      string('DECEMBER') |
      string('dec') |
      string('Dec') |
      string('DEC'));
}

/// Parse a term
class TermParser extends GrammarParser {
  TermParser() : super(const TermParserDefinition()) {}
}

/// the parser definition
class TermParserDefinition extends TermGrammarDefinition {
  const TermParserDefinition();

  simpleMonthToken() => super.simpleMonthToken().map((List each) {
        return Month(_toYear(each[1]), _toMonth(each[0]));
      });
  simpleMonthCodeToken() => super.simpleMonthCodeToken().map((String each) {
        return Month(
            _toYear(each.substring(1)), _monthCode[each.substring(0, 1)]);
      });

  simpleDayToken() => super.simpleDayToken().map((List each) {
        return Date(_toYear(each[2]), _toMonth(each[1]), int.parse(each[0]));
      });
  simpleQuarterToken() => super.simpleQuarterToken().map((List each) {
        int year = _toYear(each[2]);
        int quarter = int.parse(each[0].substring(1));
        if (quarter < 1 || quarter > 4)
          throw ArgumentError('Invalid quarter: ${each.join()}');
        int month = 3 * (quarter - 1) + 1;
        TZDateTime start = TZDateTime.utc(year, month);
        TZDateTime end = TZDateTime.utc(year, month + 3);
        return new Interval(start, end);
      });
  simpleCalYearToken() => super.simpleCalYearToken().map((List each) {
        int year = _toYear(each[1]);
        TZDateTime start = TZDateTime.utc(year);
        TZDateTime end = TZDateTime.utc(year + 1);
        return new Interval(start, end);
      });

  compoundMonthToken() => super.compoundMonthToken().map((List each) {
        DateTime start = (each[0] as Month).start;
        DateTime end = (each[2] as Month).end;
        return Interval(start, end);
      });
  compoundDayToken() => super.compoundDayToken().map((List each) {
        DateTime start = (each[0] as Date).start;
        DateTime end = (each[2] as Date).end;
        return Interval(start, end);
      });

  relativeToken() => super.relativeToken().map((List each) {
        //print(each);
        Interval res;
        Date start = Date.today(location: UTC);
        Date end;
        var aux = []
          ..add(each[0])
          ..addAll(each[1] as List);
        int step = int.parse(aux.join());
        if (each[2] == 'm') {
          end = start.add((step * 30.5).round());
        } else if (each[2] == 'y') {
          end = start.add((step * 365.25).round());
        } else if (each[2] == 'd') {
          end = start.add(step);
        } else {
          throw new ArgumentError('Unsupported relative token ${each[2]}');
        }
        if (start.isBefore(end)) {
          res = new Interval(start.start, end.end);
        } else if (start.isAfter(end)) {
          res = new Interval(end.start, start.end);
        } else {
          res = start;
        }

        return res;
      });
}

/// Convert a month token to a month value.
int _toMonth(String m) {
  int mIdx;
  if (m.length == 3) {
    mIdx = _monthIdx[m.toLowerCase()];
  } else {
    mIdx = _monthNames.indexOf(m.toLowerCase()) + 1;
  }
  if (mIdx == -1) throw new ArgumentError('Wrong month name $m');
  return mIdx;
}

/// Convert a string to a year value.  A two digit or 4 digit string.
int _toYear(String y) {
  if (!(y.length == 2 || y.length == 4))
    throw new ArgumentError('Invalid year format: $y');
  int value = int.parse(y);
  if (y.length == 2) {
    if (value > 50)
      return 1900 + value;
    else
      return 2000 + value;
  }
  return value;
}

Map<String, int> _monthCode = {
  'F': 1,
  'G': 2,
  'H': 3,
  'J': 4,
  'K': 5,
  'M': 6,
  'N': 7,
  'Q': 8,
  'U': 9,
  'V': 10,
  'X': 11,
  'Z': 12,
};

Set<String> _mon = new Set.from([
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
]);

Map _monthIdx = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12
};

List _monthNames = [
  'january',
  'february',
  'march',
  'april',
  'may',
  'june',
  'july',
  'august',
  'september',
  'october',
  'november',
  'december',
];
