library test_all;


import 'date_test.dart' as dateTest;
import 'hour_test.dart' as hourTest;
import 'interval_test.dart' as intervalTest;
import 'month_test.dart' as monthTest;
import 'term_parse_test.dart' as termParseTest;
import 'month_parse_test.dart' as monthParseTest;

main() {
  dateTest.main();
  hourTest.main();
  intervalTest.main();
  monthTest.main();
  termParseTest.main();
  monthParseTest.parseMonthTest();
}