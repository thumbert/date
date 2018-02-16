library term_parse;

import 'package:petitparser/petitparser.dart';
import 'package:date/date.dart';

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

final TermParser _parser = new TermParser();

/// Parse a limited number of String inputs into intervals using a parser.
/// 'Jan17', 'Cal17', 'Q3,18', etc.
Interval parseTerm(String term) {
  var res = _parser.parse(term);
  return res.value;
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
  simpleQuarterToken() => ref(quarterToken());
   simpleToken() => ref(simpleMonthToken) | ref(simpleDayToken); // | ref(simpleQuarterToken());

  compoundDayToken() => ref(simpleDayToken) & char('-') & ref(simpleDayToken);
  compoundMonthToken() =>
      ref(simpleMonthToken) & char('-') & ref(simpleMonthToken);
  compoundToken() => compoundMonthToken() | compoundDayToken();
  value() => ref(compoundToken) | ref(simpleToken);

  dayToken() => token(digit().repeat(1, 2));
  monthToken() => token(letter().repeat(3, 9));
  yearToken() => token(digit().repeat(2, 4));
  quarterToken() => token(char('Q') & digit() & char(',')) & yearToken();
}

/// Parse a term
class TermParser extends GrammarParser {
  /// The parser will fail with hard to understand message if input is not
  /// correct.
  TermParser() : super(const TermParserDefinition());
}

/// the parser definition
class TermParserDefinition extends TermGrammarDefinition {
  const TermParserDefinition();

  simpleMonthToken() => super.simpleMonthToken().map((List<String> each) {
        return new Month(_toYear(each[1]), _toMonth(each[0]));
      });
  simpleDayToken() => super.simpleDayToken().map((List<String> each) {
        return new Date(
            _toYear(each[2]), _toMonth(each[1]), int.parse(each[0]));
      });
  simpleQuarterToken() => super.simpleQuarterToken().map((List<String> each) {
    print(each);
  });

  compoundMonthToken() => super.compoundMonthToken().map((List<String> each) {
        DateTime start = (each[0] as Month).start;
        DateTime end = (each[2] as Month).end;
        return new Interval(start, end);
      });
  compoundDayToken() => super.compoundDayToken().map((List<String> each) {
        DateTime start = (each[0] as Date).start;
        DateTime end = (each[2] as Date).end;
        return new Interval(start, end);
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
