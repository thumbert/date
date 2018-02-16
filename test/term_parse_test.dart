library test.term_parse_test;

import 'dart:io';
import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:date/src/interval.dart';
import 'package:date/src/month.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/term_parse.dart';


parseTermTest() {
  group('Term Parse:', () {
    test('A month: jan 17, Mar 2017, JAN 17, April 17, December 17', () {
      expect(parseTerm('jan 17'), new Month(2017,1));
      expect(parseTerm('Mar 2017'), new Month(2017,3));
      expect(parseTerm('JAN 17'), new Month(2017,1));
      expect(parseTerm('April 17'), new Month(2017,4));
      expect(parseTerm('December 17'), new Month(2017,12));
    });
    test('A day: 3 jan 17, 03 jan 17', (){
      expect(parseTerm('3 jan 17'), new Date(2017,1,3));
      expect(parseTerm('03 jan 17'), new Date(2017,1,3));
      expect(parseTerm('3jan 17'), new Date(2017,1,3));
    });
    test('A quarter: Q1,17', (){
      expect(parseTerm('Q1,17'),
        new Interval(new TZDateTime.utc(2017), new TZDateTime.utc(2017,4))
      );
    });

    test('A month range: jan17-feb17', () {
      expect(parseTerm('jan17-feb17'),
          new Interval(new TZDateTime.utc(2017,1), new TZDateTime.utc(2017,3)));
    });
    test('A day range: 1jan17-3feb17', () {
      expect(parseTerm('1jan17-3feb17'),
          new Interval(new TZDateTime.utc(2017,1), new TZDateTime.utc(2017,2,4)));

    });
  });
}



main() {
  Map env = Platform.environment;
  String tzdb = env['HOME'] + '/.pub-cache/hosted/pub.dartlang.org/timezone-0.4.3/lib/data/2015b_all.tzf';
  initializeTimeZoneSync(tzdb);

  parseTermTest();

  //parser.parse('jav 17');  // blows-up

}
