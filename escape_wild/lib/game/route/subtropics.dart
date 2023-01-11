import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/app.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/dialog.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/game/items/foods.dart';
import 'package:json_annotation/json_annotation.dart';

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
      player.modifyX(Attr.health, 0.1);
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

Future<void> _showGain(ActionType action, List<ItemEntry> gain) async {
  if (gain.isEmpty) {
    await AppCtx.showTip(
      title: action.localizedName(),
      desc: "action.got-nothing".tr(),
      ok: "alright".tr(),
    );
  } else {
    final result = gain.map((e) => e.meta.localizedName()).join(", ");
    await AppCtx.showTip(
      title: action.localizedName(),
      desc: "action.got-items".tr(args: [result]),
      ok: "ok".tr(),
    );
  }
}

class PlainPlace extends SubtropicsPlace {
  static const maxExploreTimes = 3;
  static const berry = 0.6;

  PlainPlace(super.name);

  @override
  Future<void> performExplore() async {
    player.modifyX(Attr.food, -0.02);
    player.modifyX(Attr.water, -0.02);
    player.modifyX(Attr.energy, -0.08);
    final p = (maxExploreTimes - exploreCount) / maxExploreTimes;
    final gain = <ItemEntry>[];
    if (Rand.one() < berry * p) {
      final b = Foods.berry.create(mass: Rand.float(10, 30));
      gain.add(b);
    }
    player.backpack.addItemsOrMergeAll(gain);
    exploreCount++;
    await _showGain(ActionType.explore, gain);
  }

  static const type = "PlainPlace";


  @override
  String get typeName => type;
}
