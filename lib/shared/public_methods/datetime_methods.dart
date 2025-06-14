import 'package:intl/intl.dart';

String currentDateToString(DateTime dateInput) {
  String format = 'dd/MM/yyyy';
  DateFormat dateFormatter = DateFormat(format);
  String dateString = dateFormatter.format(dateInput);
  return dateString;
}

String currentDateStampToString(DateTime dateInput) {
  String format = 'dd_MM_yyyy__HH_mm_ss';
  DateFormat dateFormatter = DateFormat(format);
  String dateString = dateFormatter.format(dateInput);
  return dateString;
}

DateTime? stringToDate(String dateString) {
  if (dateString.isNotEmpty) {
    String format = 'dd/MM/yyyy';
    DateFormat dateFormatter = DateFormat(format);
    DateTime date = dateFormatter.parse(dateString);
    return date;
  } else {
    return null;
  }
}

DateTime stringToDateN(String dateString) {
  String format = 'dd/MM/yyyy';
  DateFormat dateFormatter = DateFormat(format);
  DateTime date = dateFormatter.parse(dateString);
  return date;
}
