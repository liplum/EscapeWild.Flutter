import 'package:escape_wild/ui/game/action/action.dart';
import 'package:escape_wild/ui/game/backpack/backpack.dart';
import 'package:escape_wild/ui/game/craft/craft.dart';
import 'package:escape_wild/ui/game/index.dart';
import 'package:escape_wild/ui/main/game.dart';
import 'package:escape_wild/ui/main/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final _$gameAction = GlobalKey<NavigatorState>();
final _$gameBackpack = GlobalKey<NavigatorState>();
final _$gameCraft = GlobalKey<NavigatorState>();

RoutingConfig buildRoutingConfig() {
  return RoutingConfig(
    routes: [
      GoRoute(path: "/", builder: (ctx, state) => GamePage()),
      GoRoute(path: "/settings", builder: (ctx, state) => SettingsPage()),
      GoRoute(
        path: "/game",
        redirect: (ctx, state) {
          if (state.fullPath == "/game") return "/game/action";
          return null;
        },
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (ctx, state, navigationShell) {
              return GameIndexPage(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _$gameAction,
                routes: [GoRoute(path: "/action", builder: (ctx, state) => const GameActionPage())],
              ),
              StatefulShellBranch(
                navigatorKey: _$gameBackpack,
                routes: [GoRoute(path: "/backpack", builder: (ctx, state) => const GameBackpackPage())],
              ),
              StatefulShellBranch(
                navigatorKey: _$gameCraft,
                routes: [GoRoute(path: "/craft", builder: (c, state) => const GameCraftPage())],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
