library month_parse;

import 'package:petitparser/petitparser.dart';
import 'package:date/date.dart';
import 'package:timezone/timezone.dart';

final MonthParser _parser = new MonthParser();


/// Parse a limited number of String inputs into a month term using a parser.
/// Supported tokens are:
/// <p>'Jan18', 'January 2018', 'Jan 2018', 'F18', '2018-01', '201801'
Interval parseMonth(String term, {Location location}) {
  location ??= UTC;
  var res = _parser.parse(term);
  Month month = res.value;
  return new Month(month.year, month.month, location: location);
}

class MonthGrammar extends GrammarParser {
  MonthGrammar() : super(const MonthGrammarDefinition());
}

class MonthGrammarDefinition extends GrammarDefinition {
  const MonthGrammarDefinition();

  start() => ref(value).end();
  token(Parser p) => p.flatten().trim();
  simpleMonthToken() => ref(monthToken) & ref(yearToken);
  simpleMonthCodeToken() => token(letter() & digit() & digit());
  simpleToken() =>
      ref(simpleMonthToken) |
      ref(simpleMonthCodeToken) |
      yyyymmToken();

  value() => ref(simpleToken);

  monthToken() =>
      jan() | feb() | mar() | apr() | may() | sep() | oct() | nov() | dec();
  yearToken() => token(digit().repeat(2, 4));
  yyyymmToken() => token(digit().repeat(4,4) & char('-').optional() & digit().repeat(2, 2));

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
class MonthParser extends GrammarParser {
  MonthParser() : super(const MonthParserDefinition()) {}
}

/// the parser definition
class MonthParserDefinition extends MonthGrammarDefinition {
  const MonthParserDefinition();

  simpleMonthToken() => super.simpleMonthToken().map((List<String> each) {
    return new Month(_toYear(each[1]), _toMonth(each[0]));
  });
  simpleMonthCodeToken() => super.simpleMonthCodeToken().map((String each) {
    return new Month(
        _toYear(each.substring(1)), _monthCode[each.substring(0, 1)]);
  });
  yyyymmToken() => super.yyyymmToken().map((String each) {
    int n = each.length;
    int year = int.parse(each.substring(0,4));
    int mon = int.parse(each.substring(n-2,n));
    return new Month(year, mon);
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