import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_config.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;

  SupabaseClient? get client => _initialized ? Supabase.instance.client : null;

  Future<void> initialize() async {
    if (_initialized) return;
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      // No config provided — skip initialization to keep app usable offline.
      return;
    }
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authCallbackUrlHostname: 'login-callback',
    );
    _initialized = true;
  }
}
