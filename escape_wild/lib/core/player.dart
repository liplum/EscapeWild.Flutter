import 'dart:convert';

import 'package:escape_wild/core.dart';
import 'package:escape_wild/game/route/subtropics.dart';
import 'package:flutter/cupertino.dart';
import 'package:jconverter/jconverter.dart';

final player = Player();

class Player with AttributeManagerMixin, ChangeNotifier, ExtraMixin {
  final $attrs = ValueNotifier(const AttrModel());

  /// Polymorphism serialization is required.
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

  /// Polymorphism serialization is required.
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
    routeGeneratorSeed = DateTime.now().millisecondsSinceEpoch;
    final generatedRoute = generator.generateRoute(ctx, routeGeneratorSeed);
    route = generatedRoute;
    location = generatedRoute.initialPlace;
  }

  void loadFromJson(String json) {
    loadFromJsonObj(jsonDecode(json));
  }
  void loadFromJsonObj(Map<String, dynamic> json) {
    final attrs$ = AttrModel.fromJson(json["attrs"]);
    final backpack$ = Cvt.fromJsonObj<Backpack>(json["backpack"]);
    final fireState$ = FireState.fromJson(json["fireState"]);
    final actionTimes$ = (json["actionTimes"] as num).toInt();
    final hardness$ = Contents.getHardnessByName(json["hardness"]);
    final routeGeneratorSeed$ = (json["routeGeneratorSeed"] as num).toInt();
    final route$ = Cvt.fromJsonObj<RouteProtocol>(json["route"]);
    //final
    notifyListeners();
  }

  Map<String, dynamic> toJsonObj() {
    Cvt.logger = JConverterLogger(onError: (m, e, s) => print("$m,$e,$s"));
    final json = {
      "attrs": attrs.toJson(),
      "backpack": Cvt.toJsonObj(backpack),
      "journeyProgress": journeyProgress,
      "fireState": fireState.toJson(),
      "actionTimes": actionTimes,
      "hardness": hardness.name,
      "routeGeneratorSeed": routeGeneratorSeed,
      "route": Cvt.toJsonObj(route),
    };
    final loc = location;
    final r = route;
    if (r != null && loc != null) {
      json["locationRestoreId"] = r.getPlaceRestoreId(loc);
    }
    return json;
  }

  String toJson() {
    return jsonEncode(toJsonObj());
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
