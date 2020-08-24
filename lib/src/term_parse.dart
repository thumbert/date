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
/// day ranges: 1Jan17-3Jan17, or month ranges: Jul17-Aug17, F21-H21.
///
/// <p>Or a term relative to the current moment.  For example:
/// '-10d' the last 10 days, '+10d' the next 10 days,
/// '-3m' represents approximately the last three months,
/// '-2y', represents approximately the last 2 years.
/// '-2y+1y', a compound relative, from -2 year ago to 1 year into the future.
/// The following units are supported: y or Y for years, m or M for months,
/// d or D for days.
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


class TermGrammar extends GrammarParser {
  TermGrammar() : super(const TermGrammarDefinition());
}

class TermGrammarDefinition extends GrammarDefinition {
  const TermGrammarDefinition();

  @override
  Parser start() => ref(value).end();
  Parser token(Parser p) => p.flatten().trim();
  Parser simpleDayToken() => ref(dayToken) & ref(monthToken) & ref(yearToken);
  Parser simpleMonthToken() => ref(monthToken) & ref(yearToken);
  Parser simpleMonthCodeToken() => token(letter() & digit() & digit());
  Parser simpleQuarterToken() => quarterToken();
  Parser simpleCalYearToken() => calYearToken();
  Parser simpleToken() =>
      simpleCalYearToken() |
      ref(simpleMonthToken) |
      ref(simpleMonthCodeToken) |
      ref(simpleDayToken) |
      simpleQuarterToken();

  Parser compoundDayToken() => ref(simpleDayToken) & char('-') & ref(simpleDayToken);
  Parser compoundMonthSimpleToken() =>
      ref(simpleMonthToken) & char('-') & ref(simpleMonthToken);
  Parser compoundMonthCodeToken() =>
      ref(simpleMonthCodeToken) & char('-') & ref(simpleMonthCodeToken);
  Parser compoundMonthToken() => compoundMonthSimpleToken() | compoundMonthCodeToken();
  Parser compoundRelativeToken() => relativeToken() & relativeToken();
  Parser compoundToken() => compoundMonthToken() | compoundDayToken() | compoundRelativeToken();

  Parser relativeToken() => token(char('-') | char('+')) & digit().plus() & letter();

  // compound term needs to be parsed first
  Parser value() => ref(compoundToken) | ref(simpleToken) | ref(relativeToken);

  Parser dayToken() => token(digit().repeat(1, 2));
  Parser monthToken() =>
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
  Parser yearToken() => token(digit().repeat(2, 4));
  Parser quarterToken() => token(char('Q') & digit()) & char(',') & yearToken();
  Parser calYearToken() => token((string('CAL') | string('Cal'))) & yearToken();

  Parser jan() => token(string('January') |
      string('JANUARY') |
      string('Jan') |
      string('JAN') |
      string('jan'));
  Parser feb() => token(string('February') |
      string('FEBRUARY') |
      string('feb') |
      string('Feb') |
      string('FEB'));
  Parser mar() => token(string('March') |
      string('MARCH') |
      string('mar') |
      string('Mar') |
      string('MAR'));
  Parser apr() => token(string('April') |
      string('APRIL') |
      string('apr') |
      string('Apr') |
      string('APR'));
  Parser may() => token(string('May') | string('MAY') | string('may'));
  Parser jun() => token(string('June') |
      string('JUNE') |
      string('jun') |
      string('Jun') |
      string('JUN'));
  Parser jul() => token(string('July') |
      string('JULY') |
      string('jul') |
      string('Jul') |
      string('JUL'));
  Parser aug() => token(string('August') |
      string('AUGUST') |
      string('aug') |
      string('Aug') |
      string('AUG'));
  Parser sep() => token(string('September') |
      string('SEPTEMBER') |
      string('sep') |
      string('Sep') |
      string('SEP'));
  Parser oct() => token(string('October') |
      string('OCTOBER') |
      string('oct') |
      string('Oct') |
      string('OCT'));
  Parser nov() => token(string('November') |
      string('NOVEMBER') |
      string('nov') |
      string('Nov') |
      string('NOV'));
  Parser dec() => token(string('December') |
      string('DECEMBER') |
      string('dec') |
      string('Dec') |
      string('DEC'));
}

/// Parse a term
class TermParser extends GrammarParser {
  TermParser() : super(const TermParserDefinition());
}

/// the parser definition
class TermParserDefinition extends TermGrammarDefinition {
  const TermParserDefinition();

  @override
  Parser simpleMonthToken() => super.simpleMonthToken().map((each) {
        return Month(_toYear(each[1]), _toMonth(each[0]));
      });
  @override
  Parser simpleMonthCodeToken() => super.simpleMonthCodeToken().map((each) {
        return Month(
            _toYear(each.substring(1)), _monthCode[each.substring(0, 1)]);
      });

  @override
  Parser simpleDayToken() => super.simpleDayToken().map((each) {
        return Date(_toYear(each[2]), _toMonth(each[1]), int.parse(each[0]));
      });
  @override
  Parser simpleQuarterToken() => super.simpleQuarterToken().map((each) {
        var year = _toYear(each[2]);
        var quarter = int.parse(each[0].substring(1));
        if (quarter < 1 || quarter > 4) {
          throw ArgumentError('Invalid quarter: ${each.join()}');
        }
        var month = 3 * (quarter - 1) + 1;
        var start = TZDateTime.utc(year, month);
        var end = TZDateTime.utc(year, month + 3);
        return Interval(start, end);
      });
  @override
  Parser simpleCalYearToken() => super.simpleCalYearToken().map((each) {
        var year = _toYear(each[1]);
        var start = TZDateTime.utc(year);
        var end = TZDateTime.utc(year + 1);
        return Interval(start, end);
      });

  @override
  Parser compoundMonthToken() => super.compoundMonthToken().map((each) {
        var start = (each[0] as Month).start;
        var end = (each[2] as Month).end;
        return Interval(start, end);
      });
  @override
  Parser compoundDayToken() => super.compoundDayToken().map((each) {
        var start = (each[0] as Date).start;
        var end = (each[2] as Date).end;
        return Interval(start, end);
      });

  @override
  Parser compoundRelativeToken() => super.compoundRelativeToken().map((each) {
//    print(each);
    var start = (each[0] as Interval).start;
    var end = (each[1] as Interval).end;
    return Interval(start, end);
  });

  @override
  Parser relativeToken() => super.relativeToken().map((each) {
        //print(each);
        Interval res;
        var start = Date.today(location: UTC);
        Date end;
        var aux = []
          ..add(each[0])
          ..addAll(each[1] as List);
        var step = int.parse(aux.join());
        String unit = each[2];
        if (unit.toLowerCase() == 'm') {
          end = start.add((step * 30.5).round());
        } else if (unit.toLowerCase() == 'y') {
          end = start.add((step * 365.25).round());
        } else if (unit.toLowerCase() == 'd') {
          end = start.add(step);
        } else {
          throw ArgumentError('Unsupported relative token: $unit');
        }
        if (start.isBefore(end)) {
          res = Interval(start.start, end.end);
        } else if (start.isAfter(end)) {
          res = Interval(end.start, start.end);
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
  if (mIdx == -1) throw ArgumentError('Wrong month name $m');
  return mIdx;
}

/// Convert a string to a year value.  A two digit or 4 digit string.
int _toYear(String y) {
  if (!(y.length == 2 || y.length == 4)) {
    throw ArgumentError('Invalid year format: $y');
  }
  var value = int.parse(y);
  if (y.length == 2) {
    if (value > 50) {
      return 1900 + value;
    } else {
      return 2000 + value;
    }
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
