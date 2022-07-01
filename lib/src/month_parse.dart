library month_parse;

import 'package:petitparser/petitparser.dart';
import 'package:date/date.dart';
import 'package:timezone/timezone.dart';

final _parser = MonthParserDefinition().build();

/// Parse a limited number of String inputs into a month term using a parser.
/// Supported tokens are:
/// <p>'Jan18', 'January 2018', 'Jan 2018', 'F18', '2018-01', '201801'
Month parseMonth(String term, {Location? location}) {
  location ??= UTC;
  var res = _parser.parse(term);
  Month month = res.value;
  return Month(month.year, month.month, location: location);
}

class MonthGrammarDefinition extends GrammarDefinition {
  const MonthGrammarDefinition();

  @override
  Parser start() => ref0(value).end();
  Parser token(Parser p) => p.flatten().trim();
  Parser simpleMonthToken() => ref0(monthToken) & ref0(yearToken);
  Parser simpleMonthCodeToken() => token(letter() & digit() & digit());
  Parser simpleToken() =>
      ref0(simpleMonthToken) | ref0(simpleMonthCodeToken) | yyyymmToken();

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
  Parser yyyymmToken() =>
      token(digit().repeat(4, 4) & char('-').optional() & digit().repeat(2, 2));

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
class MonthParserDefinition extends MonthGrammarDefinition {
  const MonthParserDefinition();

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
  Parser yyyymmToken() => super.yyyymmToken().map((each) {
        var n = each.length;
        var year = int.parse(each.substring(0, 4));
        var mon = int.parse(each.substring(n - 2, n));
        return Month(year, mon, location: UTC);
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
