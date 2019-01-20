# date

A [Dart](http://www.dartlang.org) package that deals with time intervals.  There are 
classes for a date, month, hour.  

From a design point of view, a month or date could be defined without a time zone, 
or in the UTC timezone.  But when combining or splitting such time intervals, 
you need to keep track of the time zone for correct calculations.  The month of 
April 2017 has a different start and end DateTime if it refers to Paris, France or 
Boston, Massachussetts.  
 
A Date object without time of day.
The calculation to go from the triple (year, month, day) to a Julian
date is taken from the R package [chron](http://CRAN.R-project.org/package=chron).

## Interval class

A class to represent the time interval between a start and end time instant.  
For example, define a year interval and split it into hours. 
```dart
var year = Interval(TZDateTime(location, 2016), TZDateTime(location, 2017));
var hours = year.splitLeft((dt) => Hour.beginning(dt));
```


## Date class

Construct a `Date`:
```dart
import 'package:date/date.dart';

var dt1 = Date(2015,1,16);    // in UTC time zone
var dt2 = Date.parse('20150106');
```

Operate on dates:
```dart
print(dt1.next);
print(dt1.previous);

dt2.add(1) == Date(2015,1,17);
dt2.subtract(1) == Date(2015,1,14);
```

Generate a sequence of dates:
```dart
var it = TimeIterable(Date(2015,1,1), Date(2016,1,1).previous);
var days = it.toList();
```

## Month class

Construct a `Month`:
```dart
import 'package:date/date.dart';
var m = Month(2017,3);  // in UTC time zone
```


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/thumbert/date/issues
