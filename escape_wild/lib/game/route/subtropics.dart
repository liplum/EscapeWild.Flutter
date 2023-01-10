import 'package:escape_wild/core.dart';

/// As the first route generator, the generating is hardcoded and not mod-friendly.
class SubtropicsRouteGenerator implements RouteGeneratorProtocol {
  @override
  RouteProtocol generateRoute(RouteGenerateContext ctx) {
    final route = SubtropicsRoute("subtropics");
    // now just try to fill the route with plain.
    final dst = ctx.hardness.journeyDistance().toInt();
    for (var i = 0; i < dst; i++) {
      route.places.add(SubtropicsPlace("plain", route));
    }
    return route;
  }
}

class SubtropicsRoute extends RouteProtocol {
  @override
  final String name;

  SubtropicsRoute(this.name);

  List<SubtropicsPlace> places = [];
  double routeProgress = 0.0;

  double getRouteProgress() => routeProgress;

  SubtropicsPlace get current => places[routeProgress.toInt().clamp(0, places.length - 1)];

  double get journeyProgress => routeProgress / (places.length - 1);

  @override
  PlaceProtocol get initialPlace => places[0];

  Future<void> setRouteProgress(double value) async {
    var old = current;
    await old.onLeave();
    routeProgress = value;
    await current.onEnter();
  }
}

class SubtropicsPlace extends PlaceProtocol with PlaceActionDelegateMixin {
  @override
  final SubtropicsRoute route;
  @override
  final String name;

  SubtropicsPlace(this.name, this.route);

  Future<void> onLeave() async {}

  Future<void> onEnter() async {}

  @override
  List<PlaceAction> getAvailableActions() {
    return [
      PlaceAction.moveWithEnergy,
      PlaceAction.exploreWithEnergy,
      PlaceAction.rest,
      PlaceAction.huntWithTool,
    ];
  }

  @override
  Future<void> performMove() async {
    player.modifyX(Attr.food, -0.05);
    player.modifyX(Attr.water, -0.05);
    player.modifyX(Attr.energy, -0.05);
    var routeProgress = route.getRouteProgress();
    await route.setRouteProgress(routeProgress + 1.0);
    player.journeyProgress = route.journeyProgress;
    player.location = route.current;
  }

  @override
  Future<void> performRest() async {
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.03);
    if (player.food > 0.0 && player.water > 0.0) {
      player.modifyX(Attr.health, 0.1);
      player.modifyX(Attr.energy, 0.25);
    } else {
      player.modifyX(Attr.energy, 0.05);
    }
  }
}

class PlainPlace extends SubtropicsPlace {
  PlainPlace(super.name, super.route);
}
