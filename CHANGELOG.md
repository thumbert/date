# Changelog

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
