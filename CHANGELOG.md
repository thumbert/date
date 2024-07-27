# Changelog

# TODO
- Investigate the speed gains from not using the Julian value to identify a date 
  but a simple int year*10000 + month*100 + day.  Should make creation of Dates 
  faster which is useful when parsing json for example. 

# Release 2024-07-27
- Add convenience method toInt() to Date and Month to return 20240415 and 202404
  for example.  Occasionally useful for storing dates or months in a db.

# Release 2024-07-19
- Overwrite the withTimeZone() method for Date and Month.

# Release 2024-04-15
- Fix bug with Hour.containing at Fall DST. 

# Release 2024-03-12
- Added a (faster) method to calculate the number of hours in a day: hoursInDay
- Replace all == argument to Object from dynamic

# Release 2023-11-12
- Bumped petitparser to 6.0.0

# Release 2023-11-08
- Add Term.generate a convenience method to create multiple terms at once
- Remove an unnecessary cast from Date hours() method 

# Release 2023-07-29
- Add static methods Date.fromInt and Month.fromInt

# Release 2023-07-28
- Document that Month.parse and Term.parse throw on incorrect input.

# Release 2023-07-08
- Rename Month.contains to Month.containing to be aligned with Hour.containing. 
- Rename Date.fromTZDateTime to Date.containing.

# Release 2023-06-28
- Add Month.contains(tzDateTime).  Always seem to be what I want to have.
  Deprecate Month.fromTZDateTime

# Release 2023-06-25
- Add number of days in month method to Month object
- Minor cleanup of tests

# Release 2023-05-31
- Bump sdk lower limit to 3.0.2
- Bump up various packages

# Release 2023-05-29
- Bump sdk upper limit to 4.0.0

# Release 2023-05-19
- Add the list of month abbreviations ['Jan', 'Feb', ...] as a static constant in Month

# Release 2023-01-12
- Add a `copyWith()` extension to TZDateTime to easily create other TZDateTime 

# 3.0.6 (released 2022-10-17)
- prettyTerm() now recognizes calendar years, e.g. 'Cal 23' and quarters, 
  e.g. 'Q3 22'. 
- added methods isQuarter() and isYear() on interval.
- bump timezone to 0.8.0
- Add a speed parser Date.fromIsoString static method.  Twice as fast as usual parsing.

# 3.0.4 (released 2022-07-01)
- Increased petitparser to 5.0.0.  
- Fix a bug parsing 'Jan23-Dec22'.  It returned the instant 2023-01-01 00:00:00 
  instead of an error.

# 3.0.3 (released 2021-12-12)
- Added package lints, apply dart fix
- Fix bug in term.withStartYear when term ends on 1-Mar

# 3.0.2 (released 2021-04-26)
- Bump up petitparser, and resolve deprecations
- Support more strings to term parser  

# 3.0.1 (released 2021-03-07)
- Introduce Date.utc, Month.utc, Quarter.utc constructors for convenience

## 3.0.0 (released 2021-03-06)
- Moved the package to null safety
- Breaking change in Date, Month, Quarter have now the timezone location 
  argument required non-null.  Could not retain the existing behavior. 

## 2.5.0 (released 2021-03-06)
- Prepare for null safety.  This is the last 
release before null safety.
- No new features, just internal refactoring  

## 2.4.0 (released 2020-09-15)
- Add a Quarter class
- Add a Term class

## 2.3.0 (released 2019-03-14)
- Mark TimeIterable as deprecated.  After using the package for a 
while, this class is not really needed.  
 - Add compareTo method for the Interval class.  

## 2.2.0 (released 2018-08-18)
- Make the package Dart 2 compliant.

## 2.1.0 (released 2018-07-01)
- Last version for Dart 1.
 
## 2.0.0
- Make Date, Month, and Hour constructors get a time zone location argument.   
- Improve the formatting of Date and Month (include an ISO format). 
- Make a Term and Month parser (see term_parse.dart and month_parse.dart).  These are 
convenient functions for parsing common intervals, or months.  
 
## 0.0.4
- Added an Interval class.

## 0.0.3
- Added a TimeIterable class.
- Added a Month class.

## 0.0.1
- Initial version
