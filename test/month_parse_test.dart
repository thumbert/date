library test.month_parse_test;

import 'dart:io';
import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';
import 'package:date/src/interval.dart';
import 'package:date/src/month.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/month_parse.dart';


parseMonthTest() {
  group('Month Parse:', () {
    test('A month: jan 17, Mar 2017, JAN 17, April 17, December 17', () {
      expect(parseMonth('Jan 17'), new Month(2017,1));
      expect(parseMonth('Mar 2017'), new Month(2017,3));
      expect(parseMonth('JAN 17'), new Month(2017,1));
      expect(parseMonth('April 17'), new Month(2017,4));
      expect(parseMonth('December 17'), new Month(2017,12));
    });
    test('A month: F17, G17, .. Z17', () {
      expect(parseMonth('F17'), new Month(2017, 1));
    });
    test('A month in ISO format: 2018-01, 201801', () {
      expect(parseMonth('2018-01'), new Month(2018, 1));
      expect(parseMonth('201801'), new Month(2018, 1));
    });
  });
}



main() async {
  Map env = Platform.environment;
  String tzdb = env['HOME'] + '/.pub-cache/hosted/pub.dartlang.org/timezone-0.4.3/lib/data/2015b_all.tzf';
  await initializeTimeZone(tzdb);

  //print(new TermParser().parse('Jan 17').value);

  /// Don't know how to test relative terms yet
//  print(new TermParser().parse('-1m').value);
//  print(new TermParser().parse('-1y').value);



  await parseMonthTest();


}
