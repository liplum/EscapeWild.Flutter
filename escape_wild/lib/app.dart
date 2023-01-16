import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/design/top.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/ui/main/home.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
final AppKey = GlobalKey<NavigatorState>();
// ignore: non_constant_identifier_names
BuildContext get AppCtx => AppKey.currentState!.context;

class EscapeWildApp extends StatefulWidget {
  const EscapeWildApp({super.key});

  @override
  State<EscapeWildApp> createState() => _EscapeWildAppState();
}

class _EscapeWildAppState extends State<EscapeWildApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Top.global(
      child: MaterialApp(
        title: 'Escape Wild',
        navigatorKey: AppKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: bakeTheme(context, ThemeData.light()),
        darkTheme: bakeTheme(context, ThemeData.dark()),
        home: const AppWrapper(),
      ),
    );
  }

  ThemeData bakeTheme(BuildContext ctx, ThemeData raw) {
    return raw.copyWith(
      cardTheme: raw.cardTheme.copyWith(
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent), //the outline color
            borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  Locale? lastLocale;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await loadL10n();
    });
  }

  @override
  Widget build(BuildContext context) {
    final newLocale = context.locale;
    if (newLocale != lastLocale) {
      lastLocale = newLocale;
      if (isL10nLoaded) {
        onLocaleChange();
      }
    }
    return const Homepage();
  }
}
