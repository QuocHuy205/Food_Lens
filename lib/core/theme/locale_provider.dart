import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefKey = 'app_locale_mode';

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    loadLocale();
  }

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_localePrefKey) ?? 'system';

    switch (mode) {
      case 'en':
        state = const Locale('en');
        break;
      case 'vi':
        state = const Locale('vi');
        break;
      default:
        state = null;
    }
  }

  Future<void> setSystem() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, 'system');
  }

  Future<void> setEnglish() async {
    state = const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, 'en');
  }

  Future<void> setVietnamese() async {
    state = const Locale('vi');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, 'vi');
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});
