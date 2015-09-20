library test_month;

import 'package:test/test.dart';
import 'package:date/src/month.dart';


test_month() {
  group("Test Month:", () {
    test("Create months from year month", (){
      Month m  = new Month(2014,1);
      Month m2 = new Month(2014,1);
      expect(m, m2);
      expect(m.toString(), "Jan14");
    });

    test("Create months from DateTime", (){
      Month m;
      m = new Month.fromDateTime(new DateTime(2014));
      expect([m.year, m.month], [2014,1]);
      m = new Month.fromDateTime(new DateTime(2014,11));
      expect([m.year, m.month], [2014,11]);
      m = new Month.fromDateTime(new DateTime(2014,12));
      expect([m.year, m.month], [2014,12]);
    });


    test("Next/previous months", (){
      expect(new Month(2014,1).next, new Month(2014,2));
      expect(new Month(2014,1).previous, new Month(2013,12));
      expect(new Month(2014,1).add(6), new Month(2014,7));
      expect(new Month(2015,11).next, new Month(2015,12));
    });

    test("Add/subtract months", (){
      Month m1 = new Month(2015,11);
      Month m3 = m1.add(1);
      expect(m3.toString(), 'Dec15');
      Month m4 = m3.add(1).subtract(1);
      expect("Dec15: (${m4.year}, ${m4.month})", "Dec15: (2015, 12)");
      expect(m1.subtract(11), new Month(2014,12));
    });

    test("Generate sequences of months", (){
      Month m = new Month(2014,1);
      expect(m.seqTo(new Month(2014,5), step: 2).map((e)=>e.toString()).join(','), "Jan14,Mar14,May14");
      expect(m.seqLength(3, step: 2).map((e)=>e.toString()).join(','), "Jan14,Mar14,May14");

      List<Month> x = [new Month(2014,3),
      new Month(2014,1)];
      x.sort();
      expect(x.map((e)=>e.toString()).join(','), "Jan14,Mar14");

      List<Month> mths = m.seqLength(12);
      expect(mths.last.year, 2014);
    });

  });


}

main() =>  test_month();