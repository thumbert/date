library datetime_ext;

import 'package:date/date.dart';
import 'package:timezone/timezone.dart';

extension DateTimeExtension on num {
  /// Convert from an Excel number to an UTC [TZDateTime] with an up to second
  /// precision. DST issues will have to be treated explicitly.
  TZDateTime fromExcelDateTime() {
    var date = Date.fromExcel(truncate());
    var r = this - truncate();
    var hour = (r * 24).truncate();
    r = (r * 24 - hour) % 24;
    var minute = (r * 60).truncate();
    r = (r * 60 - minute) % 60;
    var second = (r * 60).round();
    return TZDateTime(
      UTC,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
      second,
    );
  }
}

extension DateTimeExtension2 on DateTime {
  bool isBeginningOfHour() {
    if (millisecondsSinceEpoch / 1000 % 3600 != 0) {
      return false;
    }
    return true;
  }

  bool isMidnight() {
    if (hour != 0 || !isBeginningOfHour()) {
      return false;
    }
    return true;
  }

  bool isBeginningOfWeek() {
    if (weekday != 1 || !isMidnight()) {
      return false;
    }
    return true;
  }

  bool isBeginningOfMonth() {
    if (day != 1 || !isMidnight()) {
      return false;
    }
    return true;
  }

  bool isBeginningOfYear() {
    if (month != 1 || !isBeginningOfMonth()) {
      return false;
    }
    return true;
  }
}

extension TZDateTimeExt on TZDateTime {
  TZDateTime copyWith({
    Location? location,
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
  }) {
    return TZDateTime(
      location ?? this.location,
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
    );
  }
}

extension TZDateTimeExt2 on String {
  /// Parse a string in the extended version of the ISO 8601 format defined in 
  /// RFC9557, which includes the time zone name in square brackets. For example:
  /// format '2024-11-03T01:30:00-05:00[America/New_York]'.
  /// 
  /// This will only work if the location is available in the timezone database. 
  /// If the location is not found, an exception will be thrown.
  /// 
  TZDateTime parseRfc9557() {
    var name = substring(26, length - 1);
    var location = getLocation(name);
    return TZDateTime.parse(location, substring(0, 25)); 
  }
}
