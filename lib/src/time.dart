/// A representation of civil "wall clock" time.
/// Inspired by jiff Rust crate. See https://docs.rs/jiff/latest/jiff/

class Time {
  Time(
      {this.hours = 0,
      this.minutes = 0,
      this.seconds = 0,
      this.microseconds = 0}) {
    if (hours < 0 || hours > 23) {
      throw ArgumentError('Hours must be between 0 and 23.');
    }
    if (minutes < 0 || minutes > 59) {
      throw ArgumentError('Minutes must be between 0 and 59.');
    }
    if (seconds < 0 || seconds > 59) {
      throw ArgumentError('Seconds must be between 0 and 59.');
    }
    if (microseconds < 0 || microseconds > 999999) {
      throw ArgumentError('Microseconds must be between 0 and 999999.');
    }
  }

  final int hours;
  final int minutes;
  final int seconds;
  final int microseconds;

  static Time midnight = Time();

  static Time fromSecondsSinceMidnight(int seconds) {
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return Time(hours: hrs, minutes: mins, seconds: secs);
  }

  static Time parse(String input) {
    final timeParts = input.split(':');
    if (timeParts.length < 2 || timeParts.length > 3) {
      throw FormatException('Invalid time format: $input');
    }

    final hours = int.parse(timeParts[0]);
    final minutes = int.parse(timeParts[1]);
    int seconds = 0;
    int microseconds = 0;

    if (timeParts.length == 3) {
      final secParts = timeParts[2].split('.');
      seconds = int.parse(secParts[0]);
      if (secParts.length == 2) {
        final microStr = secParts[1].padRight(6, '0').substring(0, 6);
        microseconds = int.parse(microStr);
      }
    }

    return Time(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        microseconds: microseconds);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Time &&
          runtimeType == other.runtimeType &&
          hours == other.hours &&
          minutes == other.minutes &&
          seconds == other.seconds &&
          microseconds == other.microseconds;

  @override
  int get hashCode =>
      hours.hashCode ^
      minutes.hashCode ^
      seconds.hashCode ^
      microseconds.hashCode;

  bool operator <(Time other) {
    if (hours != other.hours) {
      return hours < other.hours;
    }
    if (minutes != other.minutes) {
      return minutes < other.minutes;
    }
    if (seconds != other.seconds) {
      return seconds < other.seconds;
    }
    return microseconds < other.microseconds;
  }

  bool operator >(Time other) => other < this;
  bool operator <=(Time other) => !(this > other);
  bool operator >=(Time other) => !(this < other);

  @override
  String toString() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String sixDigits(int n) => n.toString().padLeft(6, '0');
    if (microseconds == 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}.${sixDigits(microseconds)}';
    }
  }

  Time copyWith({int? hours, int? minutes, int? seconds, int? microseconds}) {
    return Time(
        hours: hours ?? this.hours,
        minutes: minutes ?? this.minutes,
        seconds: seconds ?? this.seconds,
        microseconds: microseconds ?? this.microseconds);
  }
}
