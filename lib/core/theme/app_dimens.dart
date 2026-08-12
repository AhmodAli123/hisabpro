import 'package:flutter/material.dart';

/// Spacing, radii, and durations. Every gap in the app comes from this scale so
/// vertical rhythm stays consistent as screens are added in later phases.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 44;

  /// Horizontal page padding.
  static const double page = 20;

  /// Extra bottom padding so content clears the navigation bar and buttons.
  static const double pageBottom = 28;
}

abstract final class AppRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// Bottom sheets are only rounded at the top.
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}

/// The design uses hairlines rather than shadows, so rule width is a token too.
abstract final class AppStroke {
  static const double hairline = 1;
  static const double rule = 1.5;
  static const double bar = 6;
}

abstract final class AppDuration {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);

  /// Gap between staggered section reveals on the dashboard.
  static const Duration stagger = Duration(milliseconds: 45);
}

/// Breakpoints for the responsive shell.
abstract final class AppBreakpoint {
  /// At or above this width the shell switches from a bottom bar to a rail.
  static const double railWidth = 640;

  /// At or above this width the dashboard lays cards out in two columns.
  static const double wideWidth = 900;
}
