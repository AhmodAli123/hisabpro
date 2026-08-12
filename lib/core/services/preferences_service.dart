import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_currencies.dart';

class SettingsService {
  SettingsService._(this._preferences);

  final SharedPreferences _preferences;

  static const String _themeModeKey = 'settings_theme_mode';
  static const String _currencyCodeKey = 'settings_currency_code';

  static Future<SettingsService> initialize() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return SettingsService._(preferences);
  }

  ThemeMode get themeMode {
    final String? value = _preferences.getString(_themeModeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Currency get currency {
    return AppCurrencies.byCode(_preferences.getString(_currencyCodeKey));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _preferences.setString(_themeModeKey, _themeModeToString(mode));
  }

  Future<void> setCurrency(Currency currency) async {
    await _preferences.setString(_currencyCodeKey, currency.code);
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}
