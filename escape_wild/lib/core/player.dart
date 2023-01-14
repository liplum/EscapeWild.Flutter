import 'dart:convert';

import 'package:escape_wild/app.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/dialog.dart';
import 'package:escape_wild/game/route/subtropics.dart';
import 'package:flutter/foundation.dart';
import 'package:rettulf/rettulf.dart';

final player = Player();
const polymorphismSave = Object();

/// It will be evaluated at runtime, no need to serialization.
const noSave = Object();

class Player with AttributeManagerMixin, ChangeNotifier, ExtraMixin {
  final $attrs = ValueNotifier(const AttrModel());
  @polymorphismSave
  var backpack = Backpack();
  var hardness = Hardness.normal;
  final $journeyProgress = ValueNotifier<Progress>(0.0);
  final $isWin = ValueNotifier(false);
  final $fireState = ValueNotifier(FireState.off);
  var routeGeneratorSeed = 0;
  @noSave
  var initialized = false;
  @noSave
  final $location = ValueNotifier<PlaceProtocol?>(null);

  @noSave
  final $maxMassLoad = ValueNotifier(2000);
  final $actionTimes = ValueNotifier(0);

  /// It's evaluated at runtime, no need to serialization.
  RouteProtocol? route;

  Future<void> performAction(ActionType action) async {
    if (action == ActionType.stopHeartbeat) {
      await onGameFailed();
    } else {
      final curLoc = location;
      if (curLoc != null) {
        await curLoc.performAction(action);
        actionTimes++;
      }
    }
  }

  List<PlaceAction> getAvailableActions() {
    if (isDead) {
      return [PlaceAction.stopHeartbeatAndLose];
    }
    return location?.getAvailableActions() ?? const [];
  }

  bool putOutCampfire() {
    if (!isFireActive) return false;
    fireState = FireState.off;
    return true;
  }

  /// return whether the tool is broken and removed.
  bool damageTool(ItemStack item, ToolComp comp, double damage) {
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

  bool canPlayerAct() {
    if(isWin) return false;
    if(isDead) return false;
    return true;
  }

  Future<void> onGameWin() async {
    await AppCtx.showTip(
      title: "Configurations!",
      desc: "You win the game after $actionTimes actions.",
      ok: "OK",
      dismissible: false,
    );
    AppCtx.navigator.pop();
  }

  Future<void> onGameFailed() async {
    await AppCtx.showTip(
      title: "YOU DIED",
      desc: "Your soul is lost in the wilderness, but you have still tried $actionTimes times.",
      ok: "Alright",
      dismissible: false,
    );
    AppCtx.navigator.pop();
  }

  Future<void> init() async {
    if (initialized) return;
  }

  Future<void> restart() async {
    await init();
    actionTimes = 0;
    attrs = AttrModel.full;
    backpack.clear();
    fireState = FireState.off;
    journeyProgress = 0;
    // Route
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
    try {
      // deserialize first to avoid unstable state when an exception is thrown.
      final attrs = AttrModel.fromJson(json["attrs"]);
      final backpack = Cvt.fromJsonObj<Backpack>(json["backpack"]);
      final fireState = FireState.fromJson(json["fireState"]);
      final actionTimes = (json["actionTimes"] as num).toInt();
      final hardness = Contents.getHardnessByName(json["hardness"]);
      final routeGeneratorSeed = (json["routeGeneratorSeed"] as num).toInt();
      final journeyProgress = (json["journeyProgress"] as num).toDouble();
      final route = Cvt.fromJsonObj<RouteProtocol>(json["route"]);
      final locationRestoreId = json["locationRestoreId"];
      final lastLocation = route!.restoreById(locationRestoreId);
      route.onRestored();
      // set fields
      this.attrs = attrs;
      this.backpack.loadFrom(backpack!);
      this.fireState = fireState;
      this.actionTimes = actionTimes;
      this.hardness = hardness;
      this.routeGeneratorSeed = routeGeneratorSeed;
      this.route = route;
      this.journeyProgress = journeyProgress;
      location = lastLocation;
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print(e);
        print(stacktrace);
      }
      throw GameSaveCorruptedError(e, stacktrace);
    }
    notifyListeners();
  }

  Map<String, dynamic> toJsonObj() {
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
      json["locationRestoreId"] = r.getRestoreIdOf(loc);
    }
    return json;
  }

  String toJson() {
    final jobj = toJsonObj();
    return Cvt.toJson(jobj) ?? "{}";
  }
}

extension PlayerX on Player {
  bool get isDead => health <= 0;

  bool get isAlive => !isDead;

  bool get isWin => $isWin.value;

  set isWin(bool v) => $isWin.value = v;

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

class GameSaveCorruptedError implements Exception {
  final Object cause;
  final StackTrace stacktrace;

  const GameSaveCorruptedError(this.cause, this.stacktrace);

  @override
  String toString() => "$cause";
}
