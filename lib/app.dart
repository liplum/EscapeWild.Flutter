import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route.dart';
import 'ui/main/error.dart';

// ignore: non_constant_identifier_names
final $key = GlobalKey<NavigatorState>();
// ignore: non_constant_identifier_names
BuildContext get $context => $key.currentState!.context;

class EscapeWildApp extends StatefulWidget {
  const EscapeWildApp({super.key});

  @override
  State<EscapeWildApp> createState() => _EscapeWildAppState();
}

class _EscapeWildAppState extends State<EscapeWildApp> {
  final $routingConfig = ValueNotifier(buildRoutingConfig());
  late final router = _buildRouter($routingConfig);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Top.global(
      child: MaterialApp.router(
        title: 'Escape Wild',
        routerConfig: router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: buildTheme(ThemeData(brightness: .light, colorSchemeSeed: Colors.yellow)),
        darkTheme: buildTheme(ThemeData(brightness: .dark, colorSchemeSeed: Colors.green)),
        builder: (ctx, child) => _PostServiceRunner(child: child ?? const SizedBox.shrink()),
      ),
    );
  }

  ThemeData buildTheme(ThemeData raw) {
    return raw.copyWith(
      cardTheme: raw.cardTheme.copyWith(shape: const RoundedRectangleBorder(borderRadius: .all(.circular(14)))),
      navigationBarTheme: raw.navigationBarTheme.copyWith(height: 68),
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
          TargetPlatform.windows: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
          TargetPlatform.linux: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  GoRouter _buildRouter(ValueNotifier<RoutingConfig> $routingConfig) {
    return GoRouter.routingConfig(
      routingConfig: $routingConfig,
      navigatorKey: $key,
      initialLocation: "/",
      debugLogDiagnostics: kDebugMode,
      errorBuilder: (ctx, state) => ErrorPage(message: state.error.toString()),
    );
  }
}

class _PostServiceRunner extends StatefulWidget {
  final Widget child;

  const _PostServiceRunner({required this.child});

  @override
  State<_PostServiceRunner> createState() => _PostServiceRunnerState();
}

class _PostServiceRunnerState extends State<_PostServiceRunner> {
  Locale? lastLocale;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final newLocale = context.locale;
    if (newLocale != lastLocale) {
      lastLocale = newLocale;
    }
    return widget.child;
  }
}
