library test.term_test;

import 'package:date/src/term.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void tests() {
  group('Term tests:', () {
    var location = getLocation('US/Eastern');
    test('with start year', () {
      var nq20 = Term.parse('Jul20-Aug20', location);
      var nq18 = nq20.withStartYear(2018);
      expect(nq18, Term.parse('Jul18-Aug18', location));
      var xh20 = Term.parse('Nov20-Mar21', location);
      var xh18 = xh20.withStartYear(2018);
      expect(xh18, Term.parse('Nov18-Mar19', location));
    });
  });
}

void main() async {
  await initializeTimeZones();
  tests();
}