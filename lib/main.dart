import 'package:brew_master/app/app_theme.dart';
import 'package:brew_master/core/app_settings.dart';
import 'package:brew_master/features/home/splash_view.dart';
import 'package:brew_master/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lottie/lottie.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize persisted settings before running app
  AppSettings.instance.init().then((_) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: settings.locale,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: settings.themeMode,
          builder: (context, mode, __) {
            return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Brew Master',
      color: Colors.transparent,
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
        return Stack(children: [
             Positioned.fill(
            child: Lottie.asset(
              'assets/image/GradientDotsBackground.json',
              // Using BoxFit.cover ensures the animation fills the screen, even if the aspect ratio doesn't match exactly
// This usually eliminates the need for an outer Center widget
              fit: BoxFit.cover,
            ),
          ),
          // subtle tint to keep content readable
          // Positioned.fill(
          //   child: DecoratedBox(
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //         colors: isDark
          //             ? [const Color(0xFF0F1115).withOpacity(0.6), const Color(0xFF0F1115).withOpacity(0.6)]
          //             : [const Color(0xFFF7F6F3).withOpacity(0.85), const Color(0xFFF2F1EE).withOpacity(0.85)],
          //       ),
          //     ),
          //   ),
          // ),
          child ?? const SizedBox.shrink(),
        ]);
      },
              home: const SplashView(),
            );
          },
        );
      },
    );
  }
}
