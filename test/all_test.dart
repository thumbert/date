library test_all;

import 'package:timezone/standalone.dart';
import 'date_test.dart' as date;
import 'hour_test.dart' as hour;
import 'interval_test.dart' as interval;
import 'month_test.dart' as month;
import 'term_test.dart' as term;
import 'term_parse_test.dart' as term_parse;
import 'month_parse_test.dart' as month_parse;
import 'quarter_test.dart' as quarter;
import 'utils_test.dart' as utils;
import 'week_test.dart' as week;

void main() async {
  await initializeTimeZone();

  date.testDate();
  hour.hourTest();
  interval.tests();
  month.tests();
  month_parse.parseMonthTest();
  quarter.tests();
  term.tests();
  term_parse.parseTermTest();
  utils.tests();
  week.tests();

}