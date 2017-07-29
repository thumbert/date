# date

A simple Date only object.  No time of day, no time zones, no problems.
The calculation to go from the triple (year, month, day) to a Julian
date is taken from the R package [chron](http://CRAN.R-project.org/package=chron).


## Usage

Construct a `Date`:
```dart
import 'package:date/date.dart';

Date dt1 = new Date(2015, 1, 1);
Date dt2 = Date.parse('20150301');
```

Operate on dates:
```dart
print(dt1.next);
print(dt1.previous);

dt2.add(1) == new Date(2015,3,2);
dt2.subtract(1) == new Date(2015,2,28);
```


Generate a sequence of dates:
```dart
TimeIterable it = new TimeIterable(new Date(2015), new Date(2016).previous);
List days = it.toList();
```


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/thumbert/date/issues
