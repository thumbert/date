library test_all;

import 'dart:io';
import 'package:timezone/standalone.dart';
import 'date_test.dart' as dateTest;
import 'hour_test.dart' as hourTest;
import 'interval_test.dart' as intervalTest;
import 'month_test.dart' as monthTest;
import 'term_parse_test.dart' as termParseTest;
import 'month_parse_test.dart' as monthParseTest;

main() async {
  await initializeTimeZone();

  dateTest.testDate();
  //dateTest.testDateIterable();

  hourTest.hourTest();
  intervalTest.testInterval();
  monthTest.testMonth();
  termParseTest.parseTermTest();
  monthParseTest.parseMonthTest();

}