library test_all;


import 'date_test.dart' as dateTest;
import 'hour_test.dart' as hourTest;
import 'interval_test.dart' as intervalTest;
import 'month_test.dart' as monthTest;

main() {
  dateTest.main();
  //hourTest.main();
  intervalTest.main();
  monthTest.main();
}