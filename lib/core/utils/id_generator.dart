import 'dart:math' as math;

/// Generates ids for records created on the device.
///
/// Time-ordered and collision-safe without pulling in a UUID package: the
/// millisecond timestamp is combined with a per-process counter and a small
/// random suffix, so two records created in the same millisecond still differ.
abstract final class IdGenerator {
  static final math.Random _random = math.Random();
  static int _counter = 0;

  static String next([String prefix = 'tx']) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    _counter = (_counter + 1) & 0xFFF;
    final int salt = _random.nextInt(0xFFFF);
    return '$prefix-$now-'
        '${_counter.toRadixString(16).padLeft(3, '0')}'
        '${salt.toRadixString(16).padLeft(4, '0')}';
  }
}
