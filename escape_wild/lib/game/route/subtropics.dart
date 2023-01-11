import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'shared.dart';

part 'subtropics.g.dart';

/// As the first route generator, the generating is hardcoded and not mod-friendly.
class SubtropicsRouteGenerator implements RouteGeneratorProtocol {
  @override
  RouteProtocol generateRoute(RouteGenerateContext ctx) {
    final route = SubtropicsRoute("subtropics");
    // now just try to fill the route with plain.
    final dst = ctx.hardness.journeyDistance().toInt();
    for (var i = 0; i < dst; i++) {
      final place = PlainPlace("plain");
      place.route = route;
      route.places.add(place);
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

@JsonSerializable()
class SubtropicsPlace extends PlaceProtocol with PlaceActionDelegateMixin {
  @override
  @JsonKey(ignore: true)
  late SubtropicsRoute route;
  @override
  @JsonKey()
  String name;
  @JsonKey()
  int exploreCount = 0;

  SubtropicsPlace(this.name);

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
      player.modifyX(Attr.health, 0.02);
      player.modifyX(Attr.energy, 0.25);
    } else {
      player.modifyX(Attr.energy, 0.05);
    }
  }

  static const type = "SubtropicsPlace";

  @override
  String get typeName => type;

  factory SubtropicsPlace.fromJson(Map<String, dynamic> json) => _$SubtropicsPlaceFromJson(json);

  Map<String, dynamic> toJson() => _$SubtropicsPlaceToJson(this);
}

class PlainPlace extends SubtropicsPlace {
  static const maxExploreTimes = 3;
  static const berry = 0.6;
  static const dirtyWater = 0.3;
  static const sticks = 0.2;
  static const cutGrass = 0.1;

  PlainPlace(super.name);

  @override
  Future<void> performExplore() async {
    player.modifyX(Attr.food, -0.02);
    player.modifyX(Attr.water, -0.02);
    player.modifyX(Attr.energy, -0.08);
    final p = (maxExploreTimes - exploreCount) / maxExploreTimes;
    final gain = <ItemEntry>[];
    randGain(berry * p, gain, () => Foods.berry.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(dirtyWater * p, gain, () => Foods.dirtyWater.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(sticks * p, gain, () => Stuff.sticks.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(cutGrass * p, gain, () => Stuff.cutGrass.create(massF: Rand.fluctuate(0.2)), 1);
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(ActionType.explore, gain);
  }

  static const type = "Subtropics.PlainPlace";

  @override
  String get typeName => type;
}

class ForestPlace extends SubtropicsPlace {
  static const maxExploreTimes = 3;
  static const berry = 0.6;
  static const nuts = 0.4;
  static const log = 0.1;
  static const dirtyWater = 0.1;

  ForestPlace(super.name);

  @override
  Future<void> performExplore() async {
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.03);
    player.modifyX(Attr.energy, -0.10);
    final p = (maxExploreTimes - exploreCount) / maxExploreTimes;
    final gain = <ItemEntry>[];
    randGain(berry * p, gain, () => Foods.berry.create(massF: Rand.fluctuate(0.2)), 2);
    randGain(dirtyWater * p, gain, () => Foods.dirtyWater.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(nuts * p, gain, () => Foods.nuts.create(massF: Rand.fluctuate(0.2)), 2);
    randGain(log * p, gain, () => Stuff.log.create(massF: Rand.fluctuate(0.2)), 1);
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(ActionType.explore, gain);
  }

  static const type = "Subtropics.ForestPlace";

  @override
  String get typeName => type;
}

class RiversidePlace extends SubtropicsPlace {
  static const maxExploreTimes = 3;
  static const berry = 0.1;
  static const stone = 0.1;
  static const clearWater = 0.8;
  static const fishing = 0.8;

  RiversidePlace(super.name);

  @override
  List<PlaceAction> getAvailableActions() {
    final res = super.getAvailableActions();
    res.add(PlaceAction.fishWithTool);
    return res;
  }

  @override
  Future<void> performFish() async {
    final tool = player.backpack.findBesToolOfType(ToolType.fishing);
    if (tool == null) return;
    final comp = tool.comp;
    final eff = comp.attr.efficiency;
    final m = 1.5 - eff;
    player.modifyX(Attr.food, -0.08 * m);
    player.modifyX(Attr.water, -0.05 * m);
    player.modifyX(Attr.energy, -0.10 * m);
    final gain = <ItemEntry>[];
    final any = randGain(fishing, gain, () => Foods.rawFish.create(massF: Rand.fluctuate(0.2)));
    player.backpack.addItemsOrMergeAll(gain);
    if (any && player.damageTool(tool.item, comp, 15.0)) {
      await showToolBroken(ActionType.explore, tool.item);
    }
    await showGain(ActionType.explore, gain);
  }

  @override
  Future<void> performExplore() async {
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.025);
    player.modifyX(Attr.energy, -0.10);
    final p = (maxExploreTimes - exploreCount) / maxExploreTimes;
    final gain = <ItemEntry>[];
    randGain(berry * p, gain, () => Foods.berry.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(clearWater * p, gain, () => Foods.clearWater.create(massF: Rand.fluctuate(0.2)), 2);
    randGain(stone * p, gain, () => Stuff.log.create(massF: Rand.fluctuate(0.2)), 1);
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(ActionType.explore, gain);
  }

  static const type = "Subtropics.RiversidePlace";

  @override
  String get typeName => type;
}

class CavePlace extends SubtropicsPlace {
  static const maxExploreTimes = 2;
  static const berry = 0.1;
  static const stone = 0.1;
  static const dirtyWater = 0.8;

  CavePlace(super.name);

  @override
  Future<void> performExplore() async {
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.03);
    player.modifyX(Attr.energy, -0.10);
    final p = (maxExploreTimes - exploreCount) / maxExploreTimes;
    final gain = <ItemEntry>[];
    randGain(dirtyWater * p, gain, () => Foods.dirtyWater.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(stone * p, gain, () => Stuff.log.create(massF: Rand.fluctuate(0.2)), 1);
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(ActionType.explore, gain);
  }

  static const type = "Subtropics.CavePlace";

  @override
  String get typeName => type;
}

class HutPlace extends SubtropicsPlace {
  static const oxe = 0.5;
  static const fishRod = 0.3;
  static const trap = 0.2;
  static const gun = 0.05;

  HutPlace(super.name);

  @override
  Future<void> performExplore() async {
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.03);
    player.modifyX(Attr.energy, -0.10);
    final gain = <ItemEntry>[];
    if (exploreCount == 0) {
      gain.addItemOrMerge(Foods.boiledWater.create());
      gain.addItemOrMerge(Foods.energyBar.create());
      if (Rand.one() < oxe) {
        gain.addItemOrMerge(Tools.oldOxe.create());
      }
    } else if (exploreCount == 1) {
      gain.addItemOrMerge(Foods.boiledWater.create());
      gain.addItemOrMerge(Foods.energyBar.create());
      if (Rand.one() < fishRod) {
        gain.addItemOrMerge(Tools.oldFishRod.create());
      }
    } else if (exploreCount == 2) {
      gain.addItemOrMergeAll(Stuff.log.repeat(2));
      final r = Rand.float(0.0, trap + gun);
      if (r < trap) {
        gain.addItemOrMerge(Tools.bearTrap.create());
      } else if (r < trap + gun) {
        gain.addItemOrMerge(Tools.oldShotgun.create());
      }
    }
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(ActionType.explore, gain);
  }

  static const type = "Subtropics.HutPlace";

  @override
  String get typeName => type;
}
