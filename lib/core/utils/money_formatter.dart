import 'package:intl/intl.dart';

import '../constants/app_currencies.dart';

/// Formats money for display.
///
/// The number locale is pinned to `en_US` on purpose: grouping and Western
/// digits stay identical no matter what locale the phone is set to, so a column
/// of amounts always lines up and never switches digit script mid-ledger.
class MoneyFormatter {
  MoneyFormatter(this.currency)
      : _plain = NumberFormat(
          _patternFor(currency.decimalDigits),
          _numberLocale,
        ),
        _compact = NumberFormat.compact(locale: _numberLocale);

  static const String _numberLocale = 'en_US';

  /// A true minus sign (U+2212), not a hyphen. It sits at the same width and
  /// height as the digits, which matters in a tabular column.
  static const String minus = '−';

  final Currency currency;
  final NumberFormat _plain;
  final NumberFormat _compact;

  static String _patternFor(int decimalDigits) {
    if (decimalDigits <= 0) return '#,##0';
    return '#,##0.${'0' * decimalDigits}';
  }

  String get mark => currency.mark;

  /// `1,550.00` — digits only, for pairing with a separately styled mark.
  String bare(num value) => _plain.format(value.abs());

  /// `SAR 1,550.00`
  String withMark(num value) => '$mark ${bare(value)}';

  /// `+8,200.00` or `−3,450.00`. Zero carries no sign.
  String signed(num value, {bool includeMark = false}) {
    final String digits = includeMark ? withMark(value) : bare(value);
    if (value > 0) return '+$digits';
    if (value < 0) return '$minus$digits';
    return digits;
  }

  /// `1.5K` — for tick labels and tight spaces.
  String compact(num value) => _compact.format(value.abs());

  /// `32%` — share of a total, guarded against division by zero.
  String percent(num part, num whole) {
    if (whole == 0) return '0%';
    final double pct = (part / whole) * 100;
    return '${pct.toStringAsFixed(pct >= 10 || pct == 0 ? 0 : 1)}%';
  }
}
