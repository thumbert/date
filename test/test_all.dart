library test_all;

import 'package:timezone/standalone.dart';
import 'date_test.dart' as date;
import 'hour_test.dart' as hour;
import 'interval_test.dart' as interval;
import 'month_test.dart' as month;
import 'term_parse_test.dart' as term_parse;
import 'month_parse_test.dart' as month_parse;
import 'week_test.dart' as week;

void main() async {
  await initializeTimeZone();

  date.testDate();
  hour.hourTest();
  interval.testInterval();
  month.testMonth();
  term_parse.parseTermTest();
  month_parse.parseMonthTest();
  week.tests();
}