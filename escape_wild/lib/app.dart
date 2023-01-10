import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/ui/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
   Future.delayed(Duration(milliseconds: 500),() {
      loadL10n();
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escape Wild',
      navigatorKey: AppKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const MainPage(),
    );
  }
}
