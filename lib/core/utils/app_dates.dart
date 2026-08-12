import 'package:intl/intl.dart';

/// Date helpers shared by the dashboard, the transaction lists, and every
/// report added in later phases.
abstract final class AppDates {
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _monthShort = DateFormat('MMM yyyy');
  static final DateFormat _dayFull = DateFormat('EEEE, d MMMM yyyy');
  static final DateFormat _dayMedium = DateFormat('d MMM yyyy');
  static final DateFormat _dayShort = DateFormat('d MMM');
  static final DateFormat _weekday = DateFormat('EEE');
  static final DateFormat _time = DateFormat('h:mm a');

  /// `August 2026`
  static String monthYear(DateTime d) => _monthYear.format(d);

  /// `Aug 2026`
  static String monthShort(DateTime d) => _monthShort.format(d);

  /// `Monday, 10 August 2026`
  static String dayFull(DateTime d) => _dayFull.format(d);

  /// `10 Aug 2026`
  static String dayMedium(DateTime d) => _dayMedium.format(d);

  /// `10 Aug`
  static String dayShort(DateTime d) => _dayShort.format(d);

  /// `Mon`
  static String weekday(DateTime d) => _weekday.format(d);

  /// `2:45 PM`
  static String time(DateTime d) => _time.format(d);

  /// Heading used to group a transaction list: `Today`, `Yesterday`, or a date.
  static String groupHeading(DateTime d, {DateTime? now}) {
    final DateTime today = startOfDay(now ?? DateTime.now());
    final DateTime target = startOfDay(d);
    final int diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) return '${weekday(d)}, ${dayShort(d)}';
    if (target.year == today.year) return dayShort(d);
    return dayMedium(d);
  }

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month);

  static DateTime endOfMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 0, 23, 59, 59, 999);

  /// Monday-based start of the week containing [d].
  static DateTime startOfWeek(DateTime d) {
    final DateTime day = startOfDay(d);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static DateTime startOfYear(DateTime d) => DateTime(d.year);

  static int daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  /// True when [d] falls inside the calendar month of [reference].
  static bool isInMonthOf(DateTime d, DateTime reference) =>
      isSameMonth(d, reference);

  /// Days already elapsed in the month of [d], counting today. Used for the
  /// average-per-day figure so it divides by real days, not the full month.
  static int elapsedDaysInMonth(DateTime d, {DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    if (!isSameMonth(d, current)) return daysInMonth(d);
    return current.day;
  }
}
