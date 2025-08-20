import 'package:brew_master/l10n/app_localizations.dart';
import 'package:brew_master/core/app_settings.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final settings = AppSettings.instance;

  void _applyLocale(Locale? locale) {
    settings.locale.value = locale;
  }

  void _applyTheme(ThemeMode mode) {
    settings.themeMode.value = mode;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.settingsLanguage, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(t.langSystem),
                selected: settings.locale.value == null,
                onSelected: (_) => _applyLocale(null),
              ),
              ChoiceChip(
                label: Text(t.langEnglish),
                selected: settings.locale.value?.languageCode == 'en',
                onSelected: (_) => _applyLocale(const Locale('en')),
              ),
              ChoiceChip(
                label: Text(t.langChineseSimplified),
                selected: settings.locale.value?.toString() == const Locale('zh', 'CN').toString(),
                onSelected: (_) => _applyLocale(const Locale('zh', 'CN')),
              ),
              ChoiceChip(
                label: Text(t.langChineseTraditional),
                selected: settings.locale.value?.toString() == const Locale('zh', 'TW').toString(),
                onSelected: (_) => _applyLocale(const Locale('zh', 'TW')),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(t.settingsTheme, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(t.themeSystem),
                selected: settings.themeMode.value == ThemeMode.system,
                onSelected: (_) => _applyTheme(ThemeMode.system),
              ),
              ChoiceChip(
                label: Text(t.themeLight),
                selected: settings.themeMode.value == ThemeMode.light,
                onSelected: (_) => _applyTheme(ThemeMode.light),
              ),
              ChoiceChip(
                label: Text(t.themeDark),
                selected: settings.themeMode.value == ThemeMode.dark,
                onSelected: (_) => _applyTheme(ThemeMode.dark),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Performance priority/simple mode switch
          // SwitchListTile(
          //   title: Text(t.settingsPerformance),
          //   subtitle: Text(t.settingsInstantHint),
          //   value: settings.performanceMode.value,
          //   onChanged: (v) => settings.performanceMode.value = v,
          // ),
          const SizedBox(height: 8),
          Text(t.settingsInstantHint, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}


