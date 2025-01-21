import 'package:escape_wild/ui/game/home.dart';
import 'package:go_router/go_router.dart';

import 'ui/main/home.dart';

// final _$main = GlobalKey<NavigatorState>();
// final _$game = GlobalKey<NavigatorState>();

RoutingConfig buildRoutingConfig() {
  return RoutingConfig(
    routes: [
      GoRoute(
        path: "/",
        redirect: (ctx, state) => "/main",
      ),
      GoRoute(
        path: "/main",
        builder: (ctx, state) => const MainHomepage(),
      ),
      GoRoute(
        path: "/game",
        builder: (ctx, state) => const GameHomepage(),
      ),
    ],
  );
}
