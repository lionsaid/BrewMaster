import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  /// null means follow system
  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  /// Default follow system
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Performance priority (disable heavy animations)
  final ValueNotifier<bool> performanceMode = ValueNotifier<bool>(false);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final sp = await SharedPreferences.getInstance();
    // locale
    final String? loc = sp.getString('settings.locale');
    if (loc == null || loc.isEmpty) {
      locale.value = null;
    } else {
      final parts = loc.split('_');
      if (parts.length == 1) {
        locale.value = Locale(parts[0]);
      } else if (parts.length == 2) {
        locale.value = Locale(parts[0], parts[1]);
      }
    }
    // theme
    final String? theme = sp.getString('settings.theme');
    if (theme != null) {
      switch (theme) {
        case 'light': themeMode.value = ThemeMode.light; break;
        case 'dark': themeMode.value = ThemeMode.dark; break;
        default: themeMode.value = ThemeMode.system; break;
      }
    }
    // performance
    performanceMode.value = sp.getBool('settings.performance') ?? false;

    // listeners to persist changes
    locale.addListener(() async {
      final v = locale.value;
      final sp = await SharedPreferences.getInstance();
      if (v == null) {
        await sp.remove('settings.locale');
      } else {
        await sp.setString('settings.locale', v.countryCode == null || v.countryCode!.isEmpty
            ? v.languageCode
            : '${v.languageCode}_${v.countryCode}');
      }
    });
    themeMode.addListener(() async {
      final sp = await SharedPreferences.getInstance();
      final t = themeMode.value;
      final s = t == ThemeMode.light ? 'light' : t == ThemeMode.dark ? 'dark' : 'system';
      await sp.setString('settings.theme', s);
    });
    performanceMode.addListener(() async {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('settings.performance', performanceMode.value);
    });
  }
}


