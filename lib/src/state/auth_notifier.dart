import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier._(this._client) {
    _init();
  }

  final SupabaseClient? _client;

  static Future<AuthNotifier> create() async {
    await SupabaseService.instance.initialize();
    return AuthNotifier._(SupabaseService.instance.client);
  }

  User? _user;

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  Future<void> _init() async {
    if (_client == null) return;
    final session = _client!.auth.currentSession;
    _user = session?.user;
    notifyListeners();
    _client!.auth.onAuthStateChange((event, session) {
      _user = session?.user;
      notifyListeners();
    });
  }

  Future<AuthResponse?> signIn(String email, String password) async {
    if (_client == null) return null;
    final res = await _client!.auth.signInWithPassword(email: email, password: password);
    return res;
  }

  Future<AuthResponse?> signUp(String email, String password) async {
    if (_client == null) return null;
    final res = await _client!.auth.signUp(email: email, password: password);
    return res;
  }

  Future<void> signOut() async {
    if (_client == null) return;
    await _client!.auth.signOut();
  }
}
