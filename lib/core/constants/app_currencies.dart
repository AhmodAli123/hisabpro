import 'package:flutter/foundation.dart';

/// A currency the app can display amounts in.
///
/// [mark] is the short text set beside a figure. It is deliberately kept as
/// plain text rather than a glyph that may be missing from the platform font.
@immutable
class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.mark,
    this.decimalDigits = 2,
  });

  /// ISO 4217 code, e.g. `SAR`. This is what gets persisted.
  final String code;

  /// Human-readable name shown in the currency picker.
  final String name;

  /// The mark rendered next to amounts, e.g. `SAR` or `৳`.
  final String mark;

  final int decimalDigits;

  @override
  bool operator ==(Object other) =>
      other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Currency($code)';
}

/// Currencies offered in Settings. Saudi Riyal is the default; the rest cover
/// the places a rial-earning user is most likely to also think in.
abstract final class AppCurrencies {
  static const Currency sar = Currency(
    code: 'SAR',
    name: 'Saudi Riyal',
    mark: 'SAR',
  );

  static const Currency bdt = Currency(
    code: 'BDT',
    name: 'Bangladeshi Taka',
    mark: '৳',
  );

  static const Currency aed = Currency(
    code: 'AED',
    name: 'UAE Dirham',
    mark: 'AED',
  );

  static const Currency usd = Currency(
    code: 'USD',
    name: 'US Dollar',
    mark: '\$',
  );

  static const Currency eur = Currency(
    code: 'EUR',
    name: 'Euro',
    mark: '€',
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    name: 'British Pound',
    mark: '£',
  );

  static const Currency inr = Currency(
    code: 'INR',
    name: 'Indian Rupee',
    mark: '₹',
  );

  static const Currency pkr = Currency(
    code: 'PKR',
    name: 'Pakistani Rupee',
    mark: '₨',
  );

  static const Currency fallback = sar;

  static const List<Currency> all = <Currency>[
    sar,
    bdt,
    aed,
    usd,
    eur,
    gbp,
    inr,
    pkr,
  ];

  /// Resolves a persisted code back to a [Currency], falling back to SAR so a
  /// corrupt or unknown preference can never leave the app without a currency.
  static Currency byCode(String? code) {
    if (code == null) return fallback;
    for (final Currency c in all) {
      if (c.code == code) return c;
    }
    return fallback;
  }
}
