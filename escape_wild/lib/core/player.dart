import 'package:escape_wild/core.dart';
import 'package:escape_wild/game/route/subtropics.dart';
import 'package:flutter/cupertino.dart';

final player = Player();

class Player with AttributeManagerMixin, ChangeNotifier, ExtraMixin {
  final $attrs = ValueNotifier(const AttrModel());
  var backpack = Backpack();
  var hardness = Hardness.normal;
  final $journeyProgress = ValueNotifier<Progress>(0.0);
  final $fireState = ValueNotifier(const FireState.off());
  var routeGeneratorSeed = 0;

  /// It's evaluated at runtime, no need to serialization.
  final $location = ValueNotifier<PlaceProtocol?>(null);

  /// It's evaluated at runtime, no need to serialization.
  final $maxMassLoad = ValueNotifier(2000);
  final $actionTimes = ValueNotifier(0);
  RouteProtocol? route;

  Future<void> performAction(ActionType action) async {
    final curLoc = location;
    if (curLoc != null) {
      await curLoc.performAction(action);
      actionTimes++;
    }
  }

  Iterable<PlaceAction> getAvailableActions() {
    return location?.getAvailableActions() ?? const [];
  }

  bool putOutCampfire() {
    if (!isFireActive) return false;
    fireState = const FireState.off();
    return true;
  }

  /// return whether the tool is broken and removed.
  bool damageTool(ItemEntry item, ToolComp comp, double damage) {
    comp.damageTool(item, damage);
    if (comp.isBroken(item)) {
      backpack.removeItem(item);
      return true;
    }
    return false;
  }

  @override
  AttrModel get attrs => $attrs.value;

  @override
  set attrs(AttrModel value) => $attrs.value = value;

  Future<void> init() async {}

  Future<void> restart() async {
    $actionTimes.value = 0;
    final generator = SubtropicsRouteGenerator();
    final ctx = RouteGenerateContext(hardness: hardness);
    routeGeneratorSeed = DateTime.now().millisecond;
    final generatedRoute = generator.generateRoute(ctx, routeGeneratorSeed);
    route = generatedRoute;
    location = generatedRoute.initialPlace;
  }

  void loadFromJson(Map<String, dynamic> json) {
    attrs = AttrModel.fromJson(json["attrs"]);

    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    final json = {
      "attrs": attrs.toJson(),
      "backpack": backpack.toJson(),
      "journeyProgress": journeyProgress,
      "fireState": fireState,
      "actionTimes": actionTimes,
      "hardness": hardness.name,
      "routeGeneratorSeed": routeGeneratorSeed,
      "route": route,
    };
    final loc = location;
    final r = route;
    if (r != null && loc != null) {
      json["locationRestoreId"] = r.getPlaceRestoreId(loc);
    }
    return json;
  }
}

extension PlayerX on Player {
  bool get isDead => health <= 0;

  bool get isAlive => !isDead;

  int get actionTimes => $actionTimes.value;

  set actionTimes(int v) => $actionTimes.value = v;

  int get maxMassLoad => $maxMassLoad.value;

  set maxMassLoad(int v) => $maxMassLoad.value = v;

  FireState get fireState => $fireState.value;

  set fireState(FireState v) => $fireState.value = v;

  bool get isFireActive => $fireState.value.active;

  set isFireActive(bool v) => $fireState.value = $fireState.value.copyWith(active: v);

  double get fireFuel => $fireState.value.fuel;

  set fireFuel(double v) => $fireState.value = $fireState.value.copyWith(fuel: v);

  PlaceProtocol? get location => $location.value;

  set location(PlaceProtocol? v) => $location.value = v;

  double get journeyProgress => $journeyProgress.value;

  set journeyProgress(double v) => $journeyProgress.value = v;

  void modifyX(Attr attr, double delta) {
    if (delta < 0) {
      delta = hardness.attrCostFix(delta);
    } else {
      delta = hardness.attrBounceFix(delta);
    }
    modify(attr, delta);
  }
}
