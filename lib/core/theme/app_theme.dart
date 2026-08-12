import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] from a [HisabPalette].
///
/// The two themes are produced by the same function, so a colour added to the
/// palette automatically reaches both modes and they cannot drift apart.
abstract final class AppTheme {
  static ThemeData light() => _build(HisabPalette.light, Brightness.light);

  static ThemeData dark() => _build(HisabPalette.dark, Brightness.dark);

  static HisabPalette paletteFor(Brightness brightness) =>
      brightness == Brightness.dark ? HisabPalette.dark : HisabPalette.light;

  static ThemeData _build(HisabPalette p, Brightness brightness) {
    final TextTheme text = AppTypography.textTheme(p.ink, p.inkSoft);

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primarySoft,
      onPrimaryContainer: p.primary,
      secondary: p.income,
      onSecondary: brightness == Brightness.dark
          ? const Color(0xFF08130F)
          : Colors.white,
      secondaryContainer: p.incomeSoft,
      onSecondaryContainer: p.income,
      tertiary: p.warning,
      onTertiary: brightness == Brightness.dark
          ? const Color(0xFF1A1509)
          : Colors.white,
      tertiaryContainer: p.warningSoft,
      onTertiaryContainer: p.warning,
      error: p.expense,
      onError: brightness == Brightness.dark
          ? const Color(0xFF2A0F0D)
          : Colors.white,
      errorContainer: p.expenseSoft,
      onErrorContainer: p.expense,
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.inkSoft,
      outline: p.rule,
      outlineVariant: p.rule,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: p.ink,
      onInverseSurface: p.surface,
      inversePrimary: p.primarySoft,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      dividerColor: p.rule,
      textTheme: text,
      primaryColor: p.primary,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineMedium,
        iconTheme: IconThemeData(color: p.ink, size: 22),
        actionsIconTheme: IconThemeData(color: p.inkSoft, size: 22),
      ),

      iconTheme: IconThemeData(color: p.inkSoft, size: 20),

      dividerTheme: DividerThemeData(
        color: p.rule,
        thickness: AppStroke.hairline,
        space: AppStroke.hairline,
      ),

      // Six destinations have to share a phone's width, so labels stay small
      // and the indicator is a quiet tint rather than a heavy pill.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primarySoft,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: AppRadius.pillAll,
        ),
        elevation: 0,
        height: 66,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 10.5,
            height: 1.1,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.1,
            color: selected ? p.primary : p.inkFaint,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 21,
            color: selected ? p.primary : p.inkFaint,
          );
        }),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.primarySoft,
        elevation: 0,
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(color: p.primary, size: 22),
        unselectedIconTheme: IconThemeData(color: p.inkFaint, size: 22),
        selectedLabelTextStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: p.primary,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: p.inkFaint,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.surfaceMuted,
          disabledForegroundColor: p.inkFaint,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          side: BorderSide(color: p.rule, width: AppStroke.rule),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: TextStyle(color: p.inkFaint, fontSize: 15),
        labelStyle: TextStyle(color: p.inkSoft, fontSize: 14),
        floatingLabelStyle: TextStyle(color: p.primary, fontSize: 13),
        prefixIconColor: p.inkFaint,
        suffixIconColor: p.inkFaint,
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: p.rule, width: AppStroke.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: p.rule, width: AppStroke.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: p.primary, width: AppStroke.rule),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: p.expense, width: AppStroke.hairline),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: p.expense, width: AppStroke.rule),
        ),
        errorStyle: TextStyle(color: p.expense, fontSize: 12.5),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: p.inkSoft,
        textColor: p.ink,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minVerticalPadding: AppSpacing.md,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surface,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        showDragHandle: true,
        dragHandleColor: p.rule,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.surface, fontSize: 14),
        actionTextColor: p.primarySoft,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceMuted,
        selectedColor: p.primarySoft,
        disabledColor: p.surfaceMuted,
        side: BorderSide(color: p.rule, width: AppStroke.hairline),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.ink,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.primary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        showCheckmark: false,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.onPrimary;
          return p.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return p.surfaceMuted;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return p.rule;
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.surfaceMuted,
        circularTrackColor: p.surfaceMuted,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.ink,
          borderRadius: AppRadius.smAll,
        ),
        textStyle: TextStyle(color: p.surface, fontSize: 12.5),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
