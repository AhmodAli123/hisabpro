import 'package:flutter/material.dart';

/// The HisabPro palette is built from ledger ink colours: iron-gall indigo for
/// structure, verdigris for money coming in, madder red for money going out,
/// and brass for warnings. Amounts are always paired with a `+`/`-` sign so
/// colour is never the only thing carrying meaning.
///
/// Every colour exists in a light ("paper") and dark ("night") variant so the
/// theme can flip without any widget needing to know which mode is active.
@immutable
class HisabPalette {
  const HisabPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.rule,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.income,
    required this.incomeSoft,
    required this.expense,
    required this.expenseSoft,
    required this.warning,
    required this.warningSoft,
  });

  /// The page the ledger is printed on.
  final Color background;

  /// Slips pasted onto the page: cards, sheets, dialogs.
  final Color surface;

  /// A quieter fill for nested rows and inactive tracks.
  final Color surfaceMuted;

  /// Primary text and figures.
  final Color ink;

  /// Supporting text.
  final Color inkSoft;

  /// Captions, disabled text, tick marks.
  final Color inkFaint;

  /// Hairline rules. The whole design uses these instead of shadows.
  final Color rule;

  final Color primary;
  final Color onPrimary;
  final Color primarySoft;

  final Color income;
  final Color incomeSoft;

  final Color expense;
  final Color expenseSoft;

  final Color warning;
  final Color warningSoft;

  static const HisabPalette light = HisabPalette(
    background: Color(0xFFEFF1EE),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF6F7F5),
    ink: Color(0xFF14202B),
    inkSoft: Color(0xFF5A6875),
    inkFaint: Color(0xFF8B97A3),
    rule: Color(0xFFDCE0DB),
    primary: Color(0xFF243F66),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE4E9F1),
    income: Color(0xFF1E5B4F),
    incomeSoft: Color(0xFFE2EDE9),
    expense: Color(0xFFA6342E),
    expenseSoft: Color(0xFFF5E4E2),
    warning: Color(0xFF8A6A1F),
    warningSoft: Color(0xFFF5EDDC),
  );

  static const HisabPalette dark = HisabPalette(
    background: Color(0xFF101822),
    surface: Color(0xFF17212D),
    surfaceMuted: Color(0xFF1D2835),
    ink: Color(0xFFE7EBEF),
    inkSoft: Color(0xFF9AA7B4),
    inkFaint: Color(0xFF6B7885),
    rule: Color(0xFF26313E),
    primary: Color(0xFF7FA8D4),
    onPrimary: Color(0xFF0C1622),
    primarySoft: Color(0xFF1B2A3D),
    income: Color(0xFF4FB399),
    incomeSoft: Color(0xFF14312B),
    expense: Color(0xFFE8776E),
    expenseSoft: Color(0xFF35201E),
    warning: Color(0xFFD8AE5A),
    warningSoft: Color(0xFF2E2718),
  );
}

/// Makes the palette reachable from any `BuildContext` without passing it down
/// the tree by hand.
class HisabTheme extends InheritedWidget {
  const HisabTheme({
    required this.palette,
    required super.child,
    super.key,
  });

  final HisabPalette palette;

  static HisabPalette of(BuildContext context) {
    final HisabTheme? inherited =
        context.dependOnInheritedWidgetOfExactType<HisabTheme>();
    if (inherited != null) return inherited.palette;
    return Theme.of(context).brightness == Brightness.dark
        ? HisabPalette.dark
        : HisabPalette.light;
  }

  @override
  bool updateShouldNotify(HisabTheme oldWidget) =>
      oldWidget.palette != palette;
}

/// `context.palette` reads better at call sites than `HisabTheme.of(context)`.
extension HisabPaletteContext on BuildContext {
  HisabPalette get palette => HisabTheme.of(this);
}
