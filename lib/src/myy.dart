library myy;

import 'package:timezone/timezone.dart';

import 'month.dart';

const _iMon = <String>[
  'F',
  'G',
  'H',
  'J',
  'K',
  'M',
  'N',
  'Q',
  'U',
  'V',
  'X',
  'Z'
];
final _mon = Map.fromIterables(_iMon, List.generate(12, (i) => i + 1));

/// Parse a string in the format MYY (e.g. 'F18') into a month.
Month parseMYY(String x, {Location? location}) {
  location ??= UTC;
  var yy = int.parse(x.substring(1));
  var year = yy > 50 ? 1900 + yy : 2000 + yy;
  var month = _mon[x.substring(0, 1).toUpperCase()]!;
  return Month(year, month, location: location);
}

/// Format a month into the MYY format.
String formatMYY(Month m) {
  var yy = (m.year % 100).toString().padLeft(2, '0');
  return '${_iMon[m.month - 1]}$yy';
}
