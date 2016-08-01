
library test.elec.interval;


import 'package:test/test.dart';
import 'package:date/src/interval.dart';

main() {

  test('interval', () {
    Interval i1 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i2 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i3 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,3));
    print(i1.toString());
    expect(i1 == i2, true);
    expect(i1 == i3, false);
  });

  test('interval abuts', () {
    Interval i1 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i2 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i3 = new Interval(new DateTime(2015,1,2), new DateTime(2015,1,3));
    expect(i1.abuts(i2), false);
    expect(i1.abuts(i3), true);
    expect(i3.abuts(i1), true);
  });

  test('interval overlap', () {
    Interval i1 = new Interval(new DateTime(2015,1,1), new DateTime(2015,1,2));
    Interval i2 = new Interval(new DateTime(2015,1,1,15), new DateTime(2015,1,3));
    //expect(i1.overlap(i2), new Interval(i2.start, i1.end));

    Interval i3 = new Interval(new DateTime(2015,1,2), new DateTime(2015,1,3));
    Interval i4 = new Interval(new DateTime(2015,1,1,15), new DateTime(2015,1,4));
    expect(i3.overlap(i4), new Interval(i3.start, i3.end));
  });


}
