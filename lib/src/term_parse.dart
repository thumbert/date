library term_parse;

import 'package:petitparser/petitparser.dart';
import 'package:date/date.dart';
import 'package:timezone/timezone.dart';

final _parser = TermParserDefinition().build();

/// Parse a limited number of String inputs into a datetime interval.
/// Supported tokens are:
/// <p>days: 1Jan17, months: 'Jan17', 'F18', years: 'Cal17', quarters: 'Q3,18',
/// day ranges: 1Jan17-3Jan17,
/// month ranges: Jul17-Aug17, F21-H21.
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
Interval? parseTerm(String term, {Location? tzLocation}) {
  var res = _parser.parse(term);
  if (res.isFailure) throw ArgumentError('Couldn\'t parse term $term.');
  var interval = res.value as Interval?;
  if (tzLocation != null) {
    var start = interval!.start;
    var end = interval.end;
    interval = Interval(
        TZDateTime(tzLocation, start.year, start.month, start.day),
        TZDateTime(tzLocation, end.year, end.month, end.day));
  }
  return interval;
}

class TermGrammarDefinition extends GrammarDefinition {
  const TermGrammarDefinition();

  @override
  Parser start() => ref0(value).end();
  Parser token(Parser p) => p.flatten().trim();
  Parser simpleDayToken() =>
      ref0(dayToken) & ref0(monthToken) & ref0(yearToken);
  Parser simpleMonthToken() => ref0(monthToken) & ref0(yearToken); // Feb21
  // Parser simpleMonthToken() => token(monthToken() & yearToken()) ;  // Feb21
  Parser simpleMonthCodeToken() => token(letter() & digit() & digit()); // G21
  Parser simpleQuarterToken() =>
      token(char('Q') & digit()) & char(',').optional() & yearToken();
  Parser simpleCalYearToken() =>
      (token((string('CAL') | string('Cal'))) & yearToken()).end() | d4().end();
  Parser simpleToken() =>
      simpleCalYearToken() |
      ref0(simpleMonthToken) |
      ref0(simpleMonthCodeToken) |
      ref0(yyyymmdd) |
      ref0(yyyymm) |
      ref0(simpleDayToken) |
      simpleQuarterToken();

  Parser compoundDayToken() =>
      ref0(simpleDayToken) & char('-') & ref0(simpleDayToken);
  Parser compoundMonthSimpleToken() =>
      ref0(simpleMonthToken) & char('-') & ref0(simpleMonthToken);
  Parser compoundMonthCodeToken() =>
      ref0(simpleMonthCodeToken) & char('-') & ref0(simpleMonthCodeToken);
  Parser compoundMonthToken() =>
      compoundMonthSimpleToken() | compoundMonthCodeToken();
  Parser compoundRelativeToken() => relativeToken() & relativeToken();
  Parser compoundToken() =>
      compoundMonthToken() | compoundDayToken() | compoundRelativeToken();

  Parser relativeToken() =>
      token(char('-') | char('+')) & digit().plus() & letter();

  // compound term needs to be parsed first
  Parser value() =>
      ref0(compoundToken) | ref0(simpleToken) | ref0(relativeToken);

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
  // Parser yearToken() => token(digit().repeat(2, 4));
  Parser d4() => token(digit().repeat(4, 4));
  Parser d2() => token(digit().repeat(2, 2));
  Parser yearToken() => token(d4() | d2());
  Parser yyyymm() => d4() & char('-').optional() & d2();
  Parser yyyymmdd() =>
      (d4() & char('-') & d2() & char('-') & d2()) | (d4() & d2() & d2());

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

/// the parser definition
class TermParserDefinition extends TermGrammarDefinition {
  const TermParserDefinition();

  @override
  Parser simpleMonthToken() => super.simpleMonthToken().map((each) {
        return Month(_toYear(each[1]), _toMonth(each[0])!, location: UTC);
      });
  @override
  Parser simpleMonthCodeToken() => super.simpleMonthCodeToken().map((each) {
        return Month(
            _toYear(each.substring(1)), _monthCode[each.substring(0, 1)]!,
            location: UTC);
      });

  @override
  Parser yyyymm() => super.yyyymm().map((each) {
        List input = each;
        if (input.length == 3) {
          input.removeAt(1);
        }
        return Month(_toYear(input[0]), int.parse(input[1]), location: UTC);
      });

  @override
  Parser yyyymmdd() => super.yyyymmdd().map((each) {
        var input =
            (each as List).where((e) => !(e == null || e == '-')).toList();
        return Date(
            int.parse(input[0]), int.parse(input[1]), int.parse(input[2]),
            location: UTC);
      });

  @override
  Parser simpleDayToken() => super.simpleDayToken().map((each) {
        return Date(_toYear(each[2]), _toMonth(each[1])!, int.parse(each[0]),
            location: UTC);
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
        late int year;
        if (each is List) {
          // it's CalYY, CalYYYY construct
          year = _toYear(each[1]);
        } else {
          // it's a yyyy
          year = _toYear(each);
        }
        var start = TZDateTime.utc(year);
        var end = TZDateTime.utc(year + 1);
        return Interval(start, end);
      });

  @override
  Parser compoundMonthToken() => super.compoundMonthToken().map((each) {
        var start = (each[0] as Month).start;
        var end = (each[2] as Month).end;
        if (!start.isBefore(end)) {
          throw ArgumentError('End month before start month!');
        }
        return Interval(start, end);
      });

  @override
  Parser compoundDayToken() => super.compoundDayToken().map((each) {
        var start = (each[0] as Date).start;
        var end = (each[2] as Date).end;
        if (!start.isBefore(end)) {
          throw ArgumentError('End day before start day!');
        }
        return Interval(start, end);
      });

  @override
  Parser compoundRelativeToken() => super.compoundRelativeToken().map((each) {
        var start = (each[0] as Interval).start;
        var end = (each[1] as Interval).end;
        return Interval(start, end);
      });

  @override
  Parser relativeToken() => super.relativeToken().map((each) {
        Interval res;
        var start = Date.today(location: UTC);
        Date end;
        var aux = [each[0], ...each[1] as List];
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
int? _toMonth(String m) {
  int? mIdx;
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
  y = y.trim();
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

const _monthCode = <String, int>{
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

const _monthIdx = <String, int>{
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

const _monthNames = <String>[
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
