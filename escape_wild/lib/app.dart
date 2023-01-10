import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/ui/home.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
final AppKey = GlobalKey<NavigatorState>();
// ignore: non_constant_identifier_names
BuildContext get AppCtx => AppKey.currentState!.context;

class EscapeWildApp extends StatelessWidget {
  const EscapeWildApp({super.key});

  // This widget is the root of your application.
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
      home: const Homepage(),
    );
  }
}
