library date_parse;

import 'package:petitparser/petitparser.dart';
import 'package:date/date.dart';
import 'package:timezone/timezone.dart';

final _parser = DateParserDefinition().build();

/// Parse a limited number of String inputs into a Date using a parser.
/// Supported tokens are:
/// <p>'5Jan18', '5Jan2018', '20180105', '2018-01-05', '1/5/2018',
///
Date parseDate(String term, {Location? location}) {
  location ??= UTC;
  var res = _parser.parse(term);
  if (res is Failure) {
    throw FormatException('Malformed input: $term');
  }
  Date date = res.value;
  return Date(date.year, date.month, date.day, location: location);
}

Date? tryParseDate(String term, {Location? location}) {
  location ??= UTC;
  var res = _parser.parse(term);
  if (res is Failure) {
    return null;
  }
  Date date = res.value;
  return Date(date.year, date.month, date.day, location: location);
}

class DateGrammarDefinition extends GrammarDefinition {
  const DateGrammarDefinition();

  @override
  Parser start() => ref0(value).end();
  Parser token(Parser p) => p.flatten().trim();
  Parser dMMMyyToken() =>
      token(digit().repeat(1, 2)) &
      char('-').optional() &
      ref0(monthToken) &
      char('-').optional() &
      ref0(yearToken);
  Parser yyyymmddToken() =>
      token(digit().repeat(4, 4)) &
      char('-').optional() &
      token(digit().repeat(2, 2)) &
      char('-').optional() &
      token(digit().repeat(2, 2));
  Parser mdyyyyToken() =>
      token(digit().repeat(1, 2)) &
      char('/') &
      token(digit().repeat(1, 2)) &
      char('/') &
      token(digit().repeat(4, 4));

  Parser simpleToken() => ref0(dMMMyyToken) | yyyymmddToken() | mdyyyyToken();

  Parser value() => ref0(simpleToken);

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


/// parser definition
class DateParserDefinition extends DateGrammarDefinition {
  const DateParserDefinition();

  @override
  Parser dMMMyyToken() => super.dMMMyyToken().map((each) {
        return Date(_toYear(each[4]), _toMonth(each[2])!, int.parse(each[0]), location: UTC);
      });
  @override
  Parser mdyyyyToken() => super.mdyyyyToken().map((each) {
        return Date(_toYear(each[4]), int.parse(each[0]), int.parse(each[2]), location: UTC);
      });
  @override
  Parser yyyymmddToken() => super.yyyymmddToken().map((each) {
        var year = int.parse(each[0]);
        var mon = int.parse(each[2]);
        var day = int.parse(each[4]);
        return Date(year, mon, day, location: UTC);
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
