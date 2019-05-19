library myy;

import 'month.dart';

List<String> _iMon = ['F','G','H','J','K','M','N','Q','U','V','X','Z'];
Map<String,int> _mon = Map.fromIterables(_iMon, List.generate(12, (i) => i+1));

/// TODO: This should be a static method in the Month class.
/// Parse a string in the format MYY (e.g. 'F18') into a month.
Month parseMYY(String x) {
  int yy = int.parse(x.substring(1));
  int year = yy > 50 ? 1900 + yy : 2000 + yy;
  int month = _mon[x.substring(0,1).toUpperCase()];
  return new Month(year, month);
}
/// Format a month into the MYY format.
String formatMYY(Month m) {
  String yy = (m.year % 100).toString().padLeft(2,'0');
  return '${_iMon[m.month-1]}$yy';
}
