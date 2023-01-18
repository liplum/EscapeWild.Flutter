import 'dart:math';

import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:noitcelloc/noitcelloc.dart';

import 'shared.dart';

part 'subtropics.g.dart';

Ts get per => actionTsStep;

final moveWithEnergy = PlaceAction(UAction.move, () => player.energy > 0.0);
final exploreWithEnergy = PlaceAction(UAction.explore, () => player.energy > 0.0);
final huntWithTool = PlaceAction(
  UAction.hunt,
  () =>
      player.energy > 0.0 &&
      player.backpack.hasAnyToolOfTypes([
        ToolType.trap,
        ToolType.gun,
      ]),
);
final fishWithTool = PlaceAction(
  UAction.fish,
  () =>
      player.energy > 0.0 &&
      player.backpack.hasAnyToolOfType(
        ToolType.fishing,
      ),
);
final cutDownTreeWithTool = PlaceAction(
  UAction.gatherGetWood,
  () =>
      player.energy > 0.0 &&
      player.backpack.hasAnyToolOfType(
        ToolType.axe,
      ),
);

bool _always() => true;
final rest = PlaceAction(UAction.shelterRest, _always);
final shelter = PlaceAction(UAction.shelter, _always);
final stopHeartbeatAndLose = PlaceAction(UAction.stopHeartbeat, _always);
final escapeWildAndWin = PlaceAction(UAction.escapeWild, _always);

@JsonSerializable()
class SubtropicsLevel extends LevelProtocol {
  @JsonKey(includeIfNull: false)
  SubtropicsRoute? route;
  @JsonKey()
  var routeSeed = 0;
  @override
  @JsonKey(toJson: Hardness.toName, fromJson: Contents.getHardnessByName)
  var hardness = Hardness.normal;

  SubtropicsLevel();

  @override
  List<PlaceAction> getAvailableActions() {
    if (player.isDead) {
      return [stopHeartbeatAndLose];
    }
    return player.location?.getAvailableActions() ?? const [];
  }

  @override
  Future<void> performAction(UAction action) async {
    if (action == UAction.stopHeartbeat) {
      await player.onGameFailed();
    } else {
      final curLoc = player.location;
      if (curLoc != null) {
        await curLoc.performAction(action);
        player.actionTimes++;
      }
    }
  }

  static const hpPer5 = 0.0003;
  static const foodPer5 = -0.008;
  static const waterPer5 = -0.008;

  @override
  Future<void> onPassTime(Ts delta) async {
    player.time += delta;
    final d = delta / per;
    player.modifyX(Attr.health, d * hpPer5);
    player.modifyX(Attr.food, d * foodPer5);
    player.modifyX(Attr.water, d * waterPer5);
    for (final stack in player.backpack.toList()) {
      await stack.onPassTime(delta);
    }
    await route?.onPassTime(delta);
  }

  factory SubtropicsLevel.fromJson(Map<String, dynamic> json) => _$SubtropicsLevelFromJson(json);

  Map<String, dynamic> toJson() => _$SubtropicsLevelToJson(this);

  static const type = "SubtropicsLevel";

  @override
  String get typeName => type;

  @override
  dynamic getLocationRestoreId(PlaceProtocol place) {
    return route!.getRestoreIdOf(place);
  }

  @override
  void onRestore() {
    route?.onRestored();
  }

  @override
  PlaceProtocol restoreLastLocation(dynamic locationRestoreId) {
    return route!.restoreById(locationRestoreId);
  }

  @override
  void onGenerateRoute() {
    final generator = SubtropicsRouteGenerator();
    final ctx = RouteGenerateContext(hardness: hardness);
    routeSeed = DateTime.now().millisecondsSinceEpoch;
    final generatedRoute = generator.generateRoute(ctx, routeSeed);
    route = generatedRoute;
    player.location = generatedRoute.initialPlace;
  }
}

/// As the first route generator, the generating is hardcoded and not mod-friendly.
class SubtropicsRouteGenerator implements RouteGeneratorProtocol<SubtropicsRoute> {
  @override
  SubtropicsRoute generateRoute(RouteGenerateContext ctx, int seed) {
    final route = SubtropicsRoute("subtropics");
    // now just try to fill the route with plain.
    final rand = Random(seed);
    final dst = ctx.hardness.journeyDistance(rand).toInt();
    route.addAll(genPlain(route, (dst * 0.35).toInt()));
    route.addAll(genForest(route, (dst * 0.2).toInt()));
    route.addAll(genRiverside(route, (dst * 0.2).toInt()));
    // randomly add a hut before cave.
    route.insert(Rand.i(0, route.placeCount), HutPlace("hut"));
    route.addAll(genCave(route, (dst * 0.1).toInt()));
    route.addAll(genPlain(route, (dst * 0.15).toInt()));
    route.add(VillagePlace("village"));
    return route;
  }

  List<SubtropicsPlace> genPlain(SubtropicsRoute route, int number) {
    final res = <SubtropicsPlace>[];
    for (var i = 0; i < number; i++) {
      final place = PlainPlace("plain");
      res.add(place);
    }
    return res;
  }

  List<SubtropicsPlace> genForest(SubtropicsRoute route, int number) {
    final res = <SubtropicsPlace>[];
    for (var i = 0; i < number; i++) {
      final place = ForestPlace("forest");
      res.add(place);
    }
    return res;
  }

  List<SubtropicsPlace> genRiverside(SubtropicsRoute route, int number) {
    final res = <SubtropicsPlace>[];
    for (var i = 0; i < number; i++) {
      final place = RiversidePlace("riverside");
      res.add(place);
    }
    return res;
  }

  List<SubtropicsPlace> genCave(SubtropicsRoute route, int number) {
    final res = <SubtropicsPlace>[];
    for (var i = 0; i < number; i++) {
      final place = CavePlace("cave");
      place.route = route;
      res.add(place);
    }
    return res;
  }
}

List<SubtropicsPlace> _placesFromJson(dynamic json) => deserializeList<SubtropicsPlace>(json);

@JsonSerializable()
class SubtropicsRoute extends RouteProtocol {
  @override
  @JsonKey()
  final String name;

  SubtropicsRoute(this.name);

  @JsonKey(fromJson: _placesFromJson)
  List<SubtropicsPlace> places = [];

  int get placeCount => places.length;

  @JsonKey()
  double routeProgress = 0.0;

  double getRouteProgress() => routeProgress;

  SubtropicsPlace get current => places[routeProgress.toInt().clamp(0, places.length - 1)];

  double get journeyProgress => routeProgress / (places.length - 1);

  @override
  PlaceProtocol get initialPlace => places[0];

  bool get canMoveForward => routeProgress.toInt() < placeCount;

  bool get canMoveBackward => 0 < routeProgress.toInt();

  @override
  Future<void> onPassTime(Ts delta) async {
    for (final place in places) {
      await place.onPassTime(delta);
    }
  }

  @override
  void onRestored() {
    for (final place in places) {
      place.route = this;
    }
  }

  void add(SubtropicsPlace place) {
    places.add(place);
    place.route = this;
  }

  void addAll(Iterable<SubtropicsPlace> places) {
    for (final place in places) {
      add(place);
    }
  }

  void insert(int index, SubtropicsPlace place) {
    places.insert(index, place);
    place.route = this;
  }

  Future<void> setRouteProgress(double value) async {
    var old = current;
    await old.onLeave();
    routeProgress = value.clamp(0, placeCount - 1);
    await current.onEnter();
  }

  @override
  String get typeName => type;

  @override
  getRestoreIdOf(covariant PlaceProtocol place) {
    return places.indexOfAny(place);
  }

  @override
  PlaceProtocol restoreById(restoreId) {
    return places[(restoreId as int).clamp(0, places.length - 1)];
  }

  factory SubtropicsRoute.fromJson(Map<String, dynamic> json) => _$SubtropicsRouteFromJson(json);

  Map<String, dynamic> toJson() => _$SubtropicsRouteToJson(this);

  static const type = "SubtropicsRoute";
}

@JsonSerializable()
class SubtropicsPlace extends CampfirePlaceProtocol with PlaceActionDelegateMixin, CampfireCookingMixin {
  /// To reduce the json size, the mod will be set later during restoration.
  @override
  @JsonKey(ignore: true)
  ModProtocol get mod => super.mod;
  @override
  @JsonKey(ignore: true)
  late SubtropicsRoute route;
  @override
  @JsonKey()
  String name;

  SubtropicsPlace(this.name);

  late final PlaceAction forward = PlaceAction(UAction.moveForward, () => route.canMoveForward);
  late final PlaceAction backward = PlaceAction(UAction.moveBackward, () => route.canMoveBackward);

  /// Short name to reduce json size.
  @JsonKey(name: "ec")
  int exploreCount = 0;
  static const hunt = 0.8;

  /// It means how much fuel will be cost after [per].
  @override
  double get fuelCostPerMinute => 2;

  Future<void> onPassTime(Ts delta) async {
    await super.onCampfirePass(delta);
  }

  @mustCallSuper
  Future<void> onLeave() async {}

  @mustCallSuper
  Future<void> onEnter() async {}

  @override
  List<PlaceAction> getAvailableActions() {
    return [
      backward,
      forward,
      exploreWithEnergy,
      shelter,
      huntWithTool,
    ];
  }

  @override
  Future<void> performMove(UAction action) async {
    await player.onPassTime(player.overallActionDuration);
    player.modifyX(Attr.food, -0.05);
    player.modifyX(Attr.water, -0.05);
    player.modifyX(Attr.energy, -0.05);
    var routeProgress = route.getRouteProgress();
    if (action == UAction.moveForward) {
      await route.setRouteProgress(routeProgress + 1.0);
    } else if (action == UAction.moveBackward) {
      await route.setRouteProgress(routeProgress - 1.0);
    }
    player.journeyProgress = route.journeyProgress;
    player.location = route.current;
  }

  @override
  Future<void> performHunt(UAction action) async {
    final tool = player.backpack.findBesToolOfTypes([ToolType.trap, ToolType.gun]);
    if (tool == null) return;
    final comp = tool.comp;
    final eff = comp.attr.efficiency;
    final m = 2.0 - eff;
    player.modifyX(Attr.food, -0.10 * m);
    player.modifyX(Attr.water, -0.12 * m);
    player.modifyX(Attr.energy, -0.20 * m);
    final gain = <ItemStack>[];
    final any = randGain(hunt, gain, () => Foods.rawRabbit.create(massF: Rand.fluctuate(0.2)));
    player.backpack.addItemsOrMergeAll(gain);
    var isToolBroken = false;
    if (any) {
      isToolBroken = player.damageTool(tool.item, comp, 30.0);
    }
    await showGain(UAction.hunt, gain);
    if (isToolBroken) {
      await showToolBroken(UAction.hunt, tool.item);
    }
  }

  @override
  Future<void> performShelter(UAction action) async {
    // TODO: A dedicate duration
    await player.onPassTime(player.overallActionDuration);
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.03);
    if (player.food > 0.0 && player.water > 0.0) {
      player.modifyX(Attr.health, 0.02);
      player.modifyX(Attr.energy, 0.25);
    } else {
      player.modifyX(Attr.energy, 0.05);
    }
  }

  static const type = "SubtropicsRoute.SubtropicsPlace";

  @override
  String get typeName => type;

  factory SubtropicsPlace.fromJson(Map<String, dynamic> json) => _$SubtropicsPlaceFromJson(json);

  Map<String, dynamic> toJson() => _$SubtropicsPlaceToJson(this);
}

@JsonSerializable()
class PlainPlace extends SubtropicsPlace {
  static const maxExploreTimes = 3;
  static const berry = 0.6;
  static const dirtyWater = 0.3;
  static const sticks = 0.2;
  static const cutGrass = 0.2;
  static const stone = 0.1;

  PlainPlace(super.name);

  @override
  Future<void> performExplore() async {
    await player.onPassTime(player.overallActionDuration);
    player.modifyX(Attr.food, -0.02);
    player.modifyX(Attr.water, -0.02);
    player.modifyX(Attr.energy, -0.08);
    final p = (maxExploreTimes - exploreCount) / maxExploreTimes;
    final gain = <ItemStack>[];
    randGain(berry * p, gain, () => Foods.berry.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(dirtyWater * p, gain, () => Foods.dirtyWater.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(sticks * p, gain, () => Stuff.sticks.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(cutGrass * p, gain, () => Stuff.cutGrass.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(stone * p, gain, () => Stuff.stone.create(massF: Rand.fluctuate(0.2)), 1);
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(UAction.explore, gain);
  }

  factory PlainPlace.fromJson(Map<String, dynamic> json) => _$PlainPlaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlainPlaceToJson(this);
  static const type = "Subtropics.PlainPlace";

  @override
  String get typeName => type;
}

@JsonSerializable()
class ForestPlace extends SubtropicsPlace {
  static const maxExploreTimes = 3;
  static const berry = 0.6;
  static const nuts = 0.4;
  static const log = 0.3;
  static const sticks = 0.4;
  static const dirtyWater = 0.1;
  static const cutDownLog = 0.9;
  static const cutDownSticks = 0.9;
  static const stone = 0.1;
  static const moss = 0.1;

  ForestPlace(super.name);

  @override
  List<PlaceAction> getAvailableActions() {
    final res = super.getAvailableActions();
    res.add(cutDownTreeWithTool);
    return res;
  }

  Future<void> performCutDownTree() async {
    await player.onPassTime(player.overallActionDuration);
    final tool = player.backpack.findBesToolOfType(ToolType.axe);
    if (tool == null) return;
    final comp = tool.comp;
    final eff = comp.attr.efficiency;
    final m = 2.0 - eff;
    player.modifyX(Attr.food, -0.12 * m);
    player.modifyX(Attr.water, -0.1 * m);
    player.modifyX(Attr.energy, -0.20 * m);
    final gain = <ItemStack>[];
    ItemStack genLog() => Stuff.log.create(massF: Rand.fluctuate(0.35));
    // at least one
    gain.add(genLog());
    var dmg = 0;
    if (randGain(cutDownLog, gain, genLog, 2)) dmg++;
    if (randGain(cutDownSticks, gain, () => Stuff.sticks.create(massF: Rand.fluctuate(0.15)), 5)) dmg++;
    randGain(nuts, gain, () => Foods.nuts.create(massF: Rand.fluctuate(0.2)), 2);
    player.backpack.addItemsOrMergeAll(gain);
    var isToolBroken = false;
    isToolBroken = player.damageTool(tool.item, comp, dmg * 30.0);
    if (isToolBroken) {
      await showToolBroken(UAction.gatherGetWood, tool.item);
    }
    await showGain(UAction.gatherGetWood, gain);
  }

  @override
  Future<void> performExplore() async {
    await player.onPassTime(player.overallActionDuration);
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.03);
    player.modifyX(Attr.energy, -0.10);
    final p = (maxExploreTimes - exploreCount) / maxExploreTimes;
    final gain = <ItemStack>[];
    randGain(berry * p, gain, () => Foods.berry.create(massF: Rand.fluctuate(0.2)), 2);
    randGain(dirtyWater * p, gain, () => Foods.dirtyWater.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(nuts * p, gain, () => Foods.nuts.create(massF: Rand.fluctuate(0.2)), 2);
    randGain(log * p, gain, () => Stuff.log.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(sticks * p, gain, () => Stuff.sticks.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(stone * p, gain, () => Stuff.stone.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(moss * p, gain, () => Foods.moss.create(massF: Rand.fluctuate(0.2)), 1);
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(UAction.explore, gain);
  }

  factory ForestPlace.fromJson(Map<String, dynamic> json) => _$ForestPlaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ForestPlaceToJson(this);
  static const type = "Subtropics.ForestPlace";

  @override
  String get typeName => type;
}

@JsonSerializable()
class RiversidePlace extends SubtropicsPlace {
  static const maxExploreTimes = 3;
  static const berry = 0.1;
  static const stone = 0.6;
  static const clearWater = 0.8;
  static const fishing = 0.8;
  static const moss = 0.2;

  RiversidePlace(super.name);

  @override
  List<PlaceAction> getAvailableActions() {
    final res = super.getAvailableActions();
    res.add(fishWithTool);
    return res;
  }

  @override
  Future<void> performFish() async {
    await player.onPassTime(player.overallActionDuration);
    final tool = player.backpack.findBesToolOfType(ToolType.fishing);
    if (tool == null) return;
    final comp = tool.comp;
    final eff = comp.attr.efficiency;
    final m = 2.0 - eff;
    player.modifyX(Attr.food, -0.08 * m);
    player.modifyX(Attr.water, -0.05 * m);
    player.modifyX(Attr.energy, -0.10 * m);
    final gain = <ItemStack>[];
    final any = randGain(fishing, gain, () => Foods.rawFish.create(massF: Rand.fluctuate(0.2)));
    player.backpack.addItemsOrMergeAll(gain);
    var isToolBroken = false;
    if (any) {
      isToolBroken = player.damageTool(tool.item, comp, 30.0);
    }
    await showGain(UAction.fish, gain);
    if (isToolBroken) {
      await showToolBroken(UAction.fish, tool.item);
    }
  }

  @override
  Future<void> performExplore() async {
    await player.onPassTime(player.overallActionDuration);
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.025);
    player.modifyX(Attr.energy, -0.10);
    final p = (maxExploreTimes - exploreCount) / maxExploreTimes;
    final gain = <ItemStack>[];
    randGain(berry * p, gain, () => Foods.berry.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(clearWater * p, gain, () => Foods.clearWater.create(massF: Rand.fluctuate(0.2)), 2);
    randGain(stone * p, gain, () => Stuff.stone.create(massF: Rand.f(1.2, 2.2)), 2);
    randGain(moss * p, gain, () => Foods.moss.create(massF: Rand.fluctuate(0.2)), 2);
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(UAction.explore, gain);
  }

  factory RiversidePlace.fromJson(Map<String, dynamic> json) => _$RiversidePlaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RiversidePlaceToJson(this);
  static const type = "Subtropics.RiversidePlace";

  @override
  String get typeName => type;
}

@JsonSerializable()
class CavePlace extends SubtropicsPlace {
  static const maxExploreTimes = 2;
  static const berry = 0.1;
  static const stone = 0.4;
  static const moss = 0.4;
  static const dirtyWater = 0.8;

  CavePlace(super.name);

  @override
  List<PlaceAction> getAvailableActions() {
    final res = super.getAvailableActions();
    // You can't hunt in cave.
    res.remove(huntWithTool);
    return res;
  }

  @override
  Future<void> performExplore() async {
    await player.onPassTime(player.overallActionDuration);
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.03);
    player.modifyX(Attr.energy, -0.10);
    final p = (maxExploreTimes - exploreCount) / maxExploreTimes;
    final gain = <ItemStack>[];
    randGain(dirtyWater * p, gain, () => Foods.dirtyWater.create(massF: Rand.fluctuate(0.2)), 1);
    randGain(stone * p, gain, () => Stuff.stone.create(massF: Rand.f(1.2, 2.2)), 2);
    randGain(moss * p, gain, () => Foods.moss.create(massF: Rand.fluctuate(0.2)), 2);
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(UAction.explore, gain);
  }

  factory CavePlace.fromJson(Map<String, dynamic> json) => _$CavePlaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CavePlaceToJson(this);
  static const type = "Subtropics.CavePlace";

  @override
  String get typeName => type;
}

@JsonSerializable()
class HutPlace extends SubtropicsPlace {
  static const axe = 0.5;
  static const fishRod = 0.3;
  static const trap = 0.2;
  static const gun = 0.05;

  HutPlace(super.name);

  @override
  Future<void> performExplore() async {
    await player.onPassTime(player.overallActionDuration);
    player.modifyX(Attr.food, -0.03);
    player.modifyX(Attr.water, -0.03);
    player.modifyX(Attr.energy, -0.08);
    final gain = <ItemStack>[];
    if (exploreCount == 0) {
      gain.addItemOrMerge(Foods.bottledWater.create());
      gain.addItemOrMerge(Foods.energyBar.create());
      if (Rand.one() < axe) {
        gain.addItemOrMerge(Tools.oldAxe.create());
      }
    } else if (exploreCount == 1) {
      gain.addItemOrMerge(Foods.bottledWater.create());
      gain.addItemOrMerge(Foods.energyBar.create());
      if (Rand.one() < fishRod) {
        gain.addItemOrMerge(Tools.oldFishRod.create());
      }
    } else if (exploreCount == 2) {
      gain.addItemOrMerge(Stuff.log.create(massF: Rand.f(1.0, 2.0)));
      final r = Rand.f(0.0, trap + gun);
      if (r < trap) {
        gain.addItemOrMerge(Tools.bearTrap.create());
      } else if (r < trap + gun) {
        gain.addItemOrMerge(Tools.oldShotgun.create());
      }
    }
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await showGain(UAction.explore, gain);
  }

  factory HutPlace.fromJson(Map<String, dynamic> json) => _$HutPlaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HutPlaceToJson(this);
  static const type = "Subtropics.HutPlace";

  @override
  String get typeName => type;
}

@JsonSerializable()
class VillagePlace extends SubtropicsPlace {
  VillagePlace(super.name);

  @override
  List<PlaceAction> getAvailableActions() {
    return [
      escapeWildAndWin,
    ];
  }

  @override
  Future<void> performOthers(UAction action) async {
    if (action == UAction.escapeWild) {
      await player.onGameWin();
    }
  }

  static const type = "Subtropics.VillagePlace";

  @override
  String get typeName => type;

  factory VillagePlace.fromJson(Map<String, dynamic> json) => _$VillagePlaceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VillagePlaceToJson(this);
}
