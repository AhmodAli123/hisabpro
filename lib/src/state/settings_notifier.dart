import 'package:flutter/material.dart';

import '../../core/constants/app_currencies.dart';
import '../../core/services/preferences_service.dart';

class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier._(
    this._service,
    this.currency,
    this.themeMode,
  );

  final SettingsService _service;

  Currency currency;
  ThemeMode themeMode;

  static Future<SettingsNotifier> create() async {
    final SettingsService service = await SettingsService.initialize();
    return SettingsNotifier._(
      service,
      service.currency,
      service.themeMode,
    );
  }

  Future<void> setCurrency(Currency nextCurrency) async {
    currency = nextCurrency;
    await _service.setCurrency(nextCurrency);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode nextThemeMode) async {
    themeMode = nextThemeMode;
    await _service.setThemeMode(nextThemeMode);
    notifyListeners();
  }
}
