import 'package:escape_wild/ui/game/action/action.dart';
import 'package:escape_wild/ui/game/backpack/backpack.dart';
import 'package:escape_wild/ui/game/craft/craft.dart';
import 'package:escape_wild/ui/game/index.dart';
import 'package:escape_wild/ui/main/game.dart';
import 'package:escape_wild/ui/main/index.dart';
import 'package:escape_wild/ui/main/mine.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final _$mainGame = GlobalKey<NavigatorState>();
final _$mainMine = GlobalKey<NavigatorState>();
final _$gameAction = GlobalKey<NavigatorState>();
final _$gameBackpack = GlobalKey<NavigatorState>();
final _$gameCraft = GlobalKey<NavigatorState>();

RoutingConfig buildRoutingConfig() {
  return RoutingConfig(
    routes: [
      GoRoute(path: "/", redirect: (ctx, state) => "/main/game"),
      GoRoute(
        path: "/main",
        redirect: (ctx, state) {
          if (state.fullPath == "/main") return "/main/game";
          return null;
        },
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (ctx, state, navigationShell) {
              return MainIndexPage(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _$mainGame,
                routes: [GoRoute(path: "/game", builder: (ctx, state) => const GamePage())],
              ),
              StatefulShellBranch(
                navigatorKey: _$mainMine,
                routes: [GoRoute(path: "/mine", builder: (ctx, state) => const MinePage())],
              ),
            ],
          ),
        ],
      ),
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
