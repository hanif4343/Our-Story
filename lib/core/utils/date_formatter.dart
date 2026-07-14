import 'package:intl/intl.dart';

/// Centralised date formatting so the whole app renders dates consistently.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _sceneDate = DateFormat('d MMMM, yyyy');
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');

  static String scene(DateTime date) => _sceneDate.format(date);
  static String short(DateTime date) => _shortDate.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// Days elapsed between the story's start date and [date].
  static int daysSince(DateTime start, DateTime date) => date.difference(start).inDays;
}
