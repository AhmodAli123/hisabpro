import 'package:flutter/material.dart';

/// Type in HisabPro carries the ledger personality through *treatment* rather
/// than through an exotic typeface: the app deliberately ships no bundled font
/// so it stays small and offline-safe, and instead leans on three distinct
/// roles built from the platform face.
///
///  * **Figures** — heavy weight, tight tracking, tabular digits so amounts
///    line up in a column exactly like a ruled ledger.
///  * **Labels** — small, tracked-out capitals for the eyebrow headings that
///    name each section.
///  * **Body** — plain and quiet, never competing with the figures.
abstract final class AppTypography {
  /// Digits all occupy the same width. Essential for columns of money.
  static const List<FontFeature> tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  /// The hero amount on the dashboard.
  static const TextStyle figureHero = TextStyle(
    fontSize: 44,
    height: 1.05,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.6,
    fontFeatures: tabular,
  );

  /// Amounts on stat slips and report headers.
  static const TextStyle figureLarge = TextStyle(
    fontSize: 26,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    fontFeatures: tabular,
  );

  /// Amounts inside list rows.
  static const TextStyle figureMedium = TextStyle(
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    fontFeatures: tabular,
  );

  /// Percentages, counts, and secondary figures.
  static const TextStyle figureSmall = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFeatures: tabular,
  );

  /// Section eyebrows: WHERE IT WENT, RECENT, THIS MONTH.
  static const TextStyle label = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.3,
  );

  /// The currency mark set beside a figure.
  static const TextStyle currencyMark = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );

  static TextTheme textTheme(Color ink, Color inkSoft) {
    return TextTheme(
      displayLarge: figureHero.copyWith(color: ink),
      displayMedium: figureLarge.copyWith(color: ink),
      headlineLarge: TextStyle(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: inkSoft,
      ),
      bodySmall: TextStyle(
        fontSize: 12.5,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: inkSoft,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: ink,
      ),
      labelMedium: label.copyWith(color: inkSoft),
      labelSmall: TextStyle(
        fontSize: 10.5,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: inkSoft,
      ),
    );
  }
}
