import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// null = follow system language.
final ValueNotifier<Locale?> localeOverride = ValueNotifier(null);

Future<void> loadLocale() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null && code.isNotEmpty) localeOverride.value = Locale(code);
  } catch (_) {}
}

Future<void> setLocale(Locale? locale) async {
  localeOverride.value = locale;
  try {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('locale');
    } else {
      await prefs.setString('locale', locale.languageCode);
    }
  } catch (_) {}
}
