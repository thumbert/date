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
        UTC, date.year, date.month, date.day, hour, minute, second);
  }
}
