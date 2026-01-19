import 'package:date/date.dart';
import 'package:test/test.dart';

void tests() {
  group('Time tests:', () {
    test('constructor and equality', () {
      var time = Time(hours: 10, minutes: 15, seconds: 30);
      expect(Time(hours: 10, minutes: 15, seconds: 30), time);
    });

    test('toString', () {
      expect(Time(hours: 10, minutes: 15, seconds: 30).toString(), '10:15:30');
      expect(
          Time(hours: 10, minutes: 15, seconds: 30, microseconds: 123456)
              .toString(),
          '10:15:30.123456');
    });

    test('comparison operators', () {
      var time1 = Time(hours: 10, minutes: 15, seconds: 30);
      var time2 = Time(hours: 12, minutes: 0, seconds: 0);
      var time3 = Time(hours: 10, minutes: 15, seconds: 30, microseconds: 1);

      expect(time1 < time2, isTrue);
      expect(time2 > time1, isTrue);
      expect(time1 <= time3, isTrue);
      expect(time3 >= time1, isTrue);
      expect(time1 < time3, isTrue);
      expect(time3 > time1, isTrue);
    });

    test('fromString', () {
      var time = Time.parse('10:15:30.123456');
      expect(time.hours, 10);
      expect(time.minutes, 15);
      expect(time.seconds, 30);
      expect(time.microseconds, 123456);

      time = Time.parse('23:59:59');
      expect(time.hours, 23);
      expect(time.minutes, 59);
      expect(time.seconds, 59);
      expect(time.microseconds, 0);

      expect(() => Time.parse('invalid'), throwsFormatException);
    });

    test('fromSecondsSinceMidnight', () {
      var time = Time.fromSecondsSinceMidnight(3661);
      expect(time.hours, 1);
      expect(time.minutes, 1);
      expect(time.seconds, 1);
      expect(time.microseconds, 0);
    });

    test('copyWith', () {
      var time = Time(hours: 10, minutes: 15, seconds: 30);
      var newTime = time.copyWith(minutes: 45);
      expect(newTime.hours, 10);
      expect(newTime.minutes, 45);
      expect(newTime.seconds, 30);
      expect(newTime.microseconds, 0);
    });

  });
}

void main() async {
  tests();
}
