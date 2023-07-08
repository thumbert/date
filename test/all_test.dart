library test_all;

import 'package:timezone/data/latest.dart';
import 'date_test.dart' as date;
import 'date_parse_test.dart' as date_parse;
import 'extensions_test.dart' as ext;
import 'hour_test.dart' as hour;
import 'interval_test.dart' as interval;
import 'month_test.dart' as month;
import 'term_test.dart' as term;
import 'term_parse_test.dart' as term_parse;
import 'month_parse_test.dart' as month_parse;
import 'quarter_test.dart' as quarter;
import 'utils_test.dart' as utils;
import 'week_test.dart' as week;

Future<void> main() async {
  initializeTimeZones();

  date.testDate();
  date_parse.tests();
  ext.tests();
  hour.tests();
  interval.tests();
  month.tests();
  month_parse.tests();
  quarter.tests();
  term.tests();
  term_parse.parseTermTest();
  utils.tests();
  week.tests();
}
