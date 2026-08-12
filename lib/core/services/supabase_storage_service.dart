import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseStorageService._();

  static final SupabaseStorageService instance = SupabaseStorageService._();

  SupabaseClient? get _client => Supabase.instance.client;

  Future<String?> uploadReceipt(String localPath, {String? filename}) async {
    if (_client == null) return null;
    try {
      final File file = File(localPath);
      if (!await file.exists()) return null;
      final String key = filename ?? '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final res = await _client!.storage.from('receipts').upload(key, file.readAsBytesSync());
      if (res.error != null) return null;
      final public = _client!.storage.from('receipts').getPublicUrl(key);
      return public.data as String?;
    } catch (e) {
      return null;
    }
  }
}
