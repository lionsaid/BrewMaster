import 'package:brew_master/app/app_theme.dart';
import 'package:brew_master/features/home/splash_view.dart';
import 'package:brew_master/core/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:brew_master/l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
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
              // 使用 BoxFit.cover 可以确保动画填满屏幕，即使比例不完全匹配
              // 这样通常可以省去外层的 Center 组件
              fit: BoxFit.cover,
            ),
          ),
          // subtle tint to keep内容可读
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
