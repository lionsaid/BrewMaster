import 'package:flutter/material.dart';

class AppSettings {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  /// null 表示跟随系统
  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  /// 默认跟随系统
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
}


