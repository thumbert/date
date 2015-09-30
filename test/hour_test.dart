library test.hour_test;

import 'package:test/test.dart';
import 'package:date/src/hour.dart';
import 'package:date/src/time_iterable.dart';
import 'package:timezone/standalone.dart';


hour_test() async {
  await initializeTimeZone();
  //Location location = getLocation('UTC');
  Location location = getLocation('US/Eastern');  // 'US/Mountain', 'US/Central', 'US/Pacific'
  group('Hour test: ', () {
    test('create hour', (){
      Hour h = new Hour.beginning(new TZDateTime(location, 2015, 1, 1));
      expect(h.end, new TZDateTime(location, 2015, 1, 1, 1));
      expect(h.toString(), 'HB: 2015-01-01 00:00:00.000-0500');
    });

    test('next/previous hour', () {
      Hour h = new Hour.beginning(new TZDateTime(location, 2015, 1, 1));
      expect(h.next, new Hour.beginning(new TZDateTime(location, 2015, 1, 1, 1)));


    });

    test('hour iterable around DST', () {
      TimeIterable it1 = new TimeIterable(
          new Hour.beginning(new TZDateTime(location, 2015, 3, 8, 0)),
          new Hour.beginning(new TZDateTime(location, 2015, 3, 8, 5)));
      //it1.forEach((h) => print(h));
      expect(it1.length, 5);  // spring forward

      TimeIterable it2 = new TimeIterable(
          new Hour.beginning(new TZDateTime(location, 2015, 11, 1, 0)),
          new Hour.beginning(new TZDateTime(location, 2015, 11, 1, 5)));
      //it2.forEach((h) => print(h));
      expect(it2.length, 7);  // fall back
    });

  });
}


main() => hour_test();

