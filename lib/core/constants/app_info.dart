/// Static facts about the build. Kept in one place so the About screen and any
/// future crash reporting read the same values.
abstract final class AppInfo {
  static const String name = 'HisabPro';
  static const String tagline = 'Keep the month honest.';
  static const String version = '1.0.0';
  static const String buildPhase = 'Phase 1 — Foundation & UI';

  static const String description =
      'HisabPro keeps a running account of what you earn and what you spend, '
      'so you always know how much of the month is left.';
}
