# date

A [Dart](http://www.dartlang.org) package that deals with time intervals.  There are 
classes for a date, month, hour.  

 
## Interval class
A class to represent the time interval between a start and end time instant.  
For example, define a year interval and split it into hours. 
```dart
var year = Interval(TZDateTime(location, 2016), TZDateTime(location, 2017));
var hours = year.splitLeft((dt) => Hour.beginning(dt));
```

## Hour class
A class to represent a given hour.
```dart
var hour = Hour.beginning(TZDateTime(utc, 2016, 1, 1));
var nextHour = hour.next;
```

## Date class
A Date is a `DateTime` object without time of day.  Construct a `Date`:
```dart
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
var m1 = Month(2017,3);  // in UTC time zone
var m2 = Month.parse('Mar17');
expect(m1, m2);
var days = m1.days();  
var may17 = m1.add(2);
```


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/thumbert/date/issues
