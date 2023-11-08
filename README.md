# date

A [Dart](http://www.dartlang.org) package that deals with time intervals.  There are 
classes for a date, month, hour.  

## Table of Contents

**[Interval](#interval-class)**  
**[Hour](#hour-class)**  
**[Date](#date-class)**  
**[Month](#month-class)**  
**[Term](#term)**  

## Interval class
A class to represent the time interval between a start (closed) and end (open) time 
instant; in mathematical notation: [start, end).  

For example, define a year interval and split it into a list of hours. 
```dart
var year = Interval(TZDateTime(location, 2016), TZDateTime(location, 2017));
var hours = year.splitLeft((dt) => Hour.beginning(dt));
```

Calculate the overlap of two intervals with ```i1.overlap(i2)```.  If there is 
no overlap, return ```null```.

To calculate the minimum interval that covers an iterable of intervals, use 
```dart
Interval coveringInterval = Interval.covering([i1, i2, i3]);
``` 

You can fuse together intervals using the static method 
```dart
List<Interval> fusedIntervals = Interval.fuse([i1, i2, i3, i4, i5]);
```

  


## Hour class
A class to represent a given hour.
```dart
var hour = Hour.beginning(TZDateTime(UTC, 2016));
var nextHour = hour.next;
```

## Date class
A Date is a `DateTime` object without time of day.  Construct a `Date`:
```dart
var dt1 = Date.utc(2015,1,16);    // in UTC time zone
var dt2 = Date.parse('20150106');
```

Operate on dates:
```dart
print(dt1.next);
print(dt1.previous);

dt2.add(1) == Date.utc(2015,1,17);
dt2.subtract(1) == Date.utc(2015,1,14);
```


## Month class
Construct a `Month`:
```dart
var m1 = Month.utc(2017,3);  
var m2 = Month.parse('Mar17'); // 'H17', '2017-03', 'March 2017' work
expect(m1, m2);
var days = m1.days();  // get the list of days in this month 
var may17 = m1.add(2);
```
To generate a list of months preceding or following a given month use
```dart
m1.next; // Apr17
m1.previous(12); // previous 12 months 
m1.nextN(12); // next 12 months from Mar17 (not included), e.g [Apr17, ... Mar18]
m1.upTo(Month(2017,12)); // [Mar17, Apr17, May17, ... Dec17]  
```

## Term

Term is a higher level interval-like concept that has a start and end **`Date`**
(no hours).  

It comes with a parser for date intervals based on a proper grammar.  You can parse 
* a Date, e.g. '13Jan21', '2021-01-13'
* a Month, e.g. 'Jan21', 'January 2021', 'Jan 2021', 'F21', '2021-01'
* a Quarter, e.g. 'Q2, 21', 'Q2 2021', 'Q2, 2021'
* a calendar Year, e.g. 'Cal2021', 'Cal 2021', 'Cal21', '2021'

or ranges
* a Date range, e.g. '13Jan21-21Feb22'
* a Month range, e.g. 'Jan21-Mar21', 'F21-G21', 

or intervals relative to the current date 
* e.g. -3d for the last 3 days, +7d for the next 7 days
* e.g. -3m for the last 3 months, +7m for the next 7 months
* e.g. -3y for the last 3 years, +7y for the next 7 years
* and combinations of past/future periods, e.g. -3d+7d, -3m+7m, -1y+1y, etc.

For example
```dart
Term.parse('Q3,2017');
Term.parse('Cal22');
Term.parse('-3m+7d');
Term.parse('Jan22-Jun22');
Term.parse('3Jan22-15Jun22');
```

You can generate several terms at once with `Term.generate`.  For example
```dart
Term.generate([2022,2023], location: UTC); // ['Jan22-Dec22', 'Jan23-Dec23']
Term.generate([2022,2023], monthRange: (12,3), location: UTC); // ['Dec22-Mar23', 'Dec23-Mar24']
Term.generate([2022,2023], monthRange: (12,3), dayRange: (5,10), location: UTC); // ['5Dec22-10Mar23', '5Dec23-10Mar24']
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/thumbert/date/issues
