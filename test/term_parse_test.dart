library test.term_parse_test;

import 'dart:io';
import 'package:test/test.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';
import 'package:date/src/interval.dart';
import 'package:date/src/month.dart';
import 'package:date/src/date_base.dart';
import 'package:date/src/term_parse.dart';


parseTermTest() {
  group('Term Parse:', () {
    test('A month: jan 17, Mar 2017, JAN 17, April 17, December 17', () {
      expect(parseTerm('Jan 17'), new Month(2017,1));
      expect(parseTerm('Mar 2017'), new Month(2017,3));
      expect(parseTerm('JAN 17'), new Month(2017,1));
      expect(parseTerm('April 17'), new Month(2017,4));
      expect(parseTerm('December 17'), new Month(2017,12));
    });
    test('A month: F17, G17, .. Z17', () {
      expect(parseTerm('F17'), new Month(2017, 1));
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
    test('A quarter: Q1, 2017', (){
      expect(parseTerm('Q1, 2017'),
          new Interval(new TZDateTime.utc(2017), new TZDateTime.utc(2017,4))
      );
    });
    test('A calendar year: CAL2017, Cal 2017', () {
      expect(parseTerm('CAL2017'),
          new Interval(new TZDateTime.utc(2017), new TZDateTime.utc(2018)));
      expect(parseTerm('Cal 2017'),
          new Interval(new TZDateTime.utc(2017), new TZDateTime.utc(2018)));
    });
//    test('A relative token: -1m, -1y', () {  /// DON't know how to test them
//      //Date today = Date.today(location: UTC);
//      expect(parseTerm('-1b'), matcher)
//    });

    test('A month range: jan17-feb17, jan17 - feb17, jan17-Feb17', () {
      expect(parseTerm('jan17-feb17'),
          new Interval(new TZDateTime.utc(2017,1), new TZDateTime.utc(2017,3)));
      expect(parseTerm('jan17 - feb17'),
          new Interval(new TZDateTime.utc(2017,1), new TZDateTime.utc(2017,3)));
      expect(parseTerm('jan17-Feb17'),
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

  //print(new TermParser().parse('Jan 17').value);

  /// Don't know how to test relative terms yet
//  print(new TermParser().parse('-1m').value);
//  print(new TermParser().parse('-1y').value);



  parseTermTest();


}
