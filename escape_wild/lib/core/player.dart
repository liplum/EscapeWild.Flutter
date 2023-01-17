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

const actionTsStep = TS(minutes: 5);
const maxActionDuration = TS.hm(hour: 2, minute: 0);

class Player with AttributeManagerMixin, ChangeNotifier, ExtraMixin {
  final $attrs = ValueNotifier(const AttrModel());
  @polymorphismSave
  var backpack = Backpack();
  final $journeyProgress = ValueNotifier<Progress>(0.0);
  final $isWin = ValueNotifier(false);
  @noSave
  var initialized = false;
  @noSave
  final $location = ValueNotifier<PlaceProtocol?>(null);
  @noSave
  final $maxMassLoad = ValueNotifier(10000);
  final $actionTimes = ValueNotifier(0);
  static const startClock = Clock.hm(hour: 7, minute: 0);
  final $time = ValueNotifier(TS.zero);
  final $overallActionDuration = ValueNotifier(const TS(minutes: 30));
  var _isExecutingOnPass = false;
  LevelProtocol level = LevelProtocol.empty;

  Future<void> onPass(TS delta) async {
    assert( !_isExecutingOnPass, "[onPass] can't be called recursively.");
    if (_isExecutingOnPass) return;
    _isExecutingOnPass = true;
    // update multiple times.
    final updateTimes = (delta / actionTsStep).toInt();
    for (var i = 0; i < updateTimes; i++) {
      await level.onPass(actionTsStep);
    }
    _isExecutingOnPass = false;
  }

  Future<void> performAction(UAction action) {
    return level.performAction(action);
  }

  List<PlaceAction> getAvailableActions() {
    return level.getAvailableActions();
  }

  /// return whether the tool is broken and removed.
  bool damageTool(ItemStack item, ToolComp comp, double damage) {
    comp.damageTool(item, damage);
    if (comp.isBroken(item)) {
      backpack.removeStack(item);
      return true;
    }
    return false;
  }

  @override
  AttrModel get attrs => $attrs.value;

  @override
  set attrs(AttrModel value) => $attrs.value = value;

  bool canPlayerAct() {
    if (isWin) return false;
    if (isDead) return false;
    return true;
  }

  Future<void> onGameWin() async {
    await AppCtx.showTip(
      title: "Congratulation!",
      desc: "You win the game after $actionTimes actions.",
      ok: "OK",
      dismissible: false,
    );
    AppCtx.navigator.pop();
  }

  Future<void> onGameFailed() async {
    await AppCtx.showTip(
      title: "YOU DIED",
      desc:
          "Your soul is lost in the wilderness, but you have still tried $actionTimes times and last ${time.hourPart} hours ${time.minutePart} minutes.",
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
    _isExecutingOnPass = false;
    actionTimes = 0;
    attrs = AttrModel.full;
    backpack.clear();
    journeyProgress = 0;
    // Create level.
    final level = SubtropicsLevel();
    this.level = level;
    level.onGenerateRoute();
  }

  void loadFromJson(String json) {
    loadFromJsonObj(jsonDecode(json));
  }

  void loadFromJsonObj(Map<String, dynamic> json) {
    try {
      // deserialize first to avoid unstable state when an exception is thrown.
      final attrs = AttrModel.fromJson(json["attrs"]);
      final backpack = Cvt.fromJsonObj<Backpack>(json["backpack"]);
      final actionTimes = (json["actionTimes"] as num).toInt();
      final journeyProgress = (json["journeyProgress"] as num).toDouble();
      final level = Cvt.fromJsonObj<LevelProtocol>(json["level"]);
      final locationRestoreId = json["locationRestoreId"];
      final lastLocation = level!.restoreLastLocation(locationRestoreId);
      level.onRestore();
      // set fields
      this.attrs = attrs;
      this.backpack.loadFrom(backpack!);
      this.backpack.validate();
      this.actionTimes = actionTimes;
      this.level = level;
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
    backpack.validate();
    final json = {
      "attrs": attrs.toJson(),
      "backpack": Cvt.toJsonObj(backpack),
      "journeyProgress": journeyProgress,
      "actionTimes": actionTimes,
      "level": Cvt.toJsonObj(level),
      "locationRestoreId": level.getLocationRestoreId(location!),
    };
    return json;
  }

  String toJson({int? indent}) {
    final jobj = toJsonObj();
    return Cvt.toJson(jobj, indent: indent) ?? "{}";
  }
}

extension PlayerX on Player {
  bool get isDead => health <= 0;

  bool get isAlive => !isDead;

  bool get isWin => $isWin.value;

  set isWin(bool v) => $isWin.value = v;

  TS get overallActionDuration => $overallActionDuration.value;

  set overallActionDuration(TS v) => $overallActionDuration.value = v;

  TS get time => $time.value;

  set time(TS v) => $time.value = v;

  int get actionTimes => $actionTimes.value;

  set actionTimes(int v) => $actionTimes.value = v;

  int get maxMassLoad => $maxMassLoad.value;

  set maxMassLoad(int v) => $maxMassLoad.value = v;

  PlaceProtocol? get location => $location.value;

  set location(PlaceProtocol? v) => $location.value = v;

  double get journeyProgress => $journeyProgress.value;

  set journeyProgress(double v) => $journeyProgress.value = v;

  void modifyX(Attr attr, double delta) {
    if (delta < 0) {
      delta = level.hardness.attrCostFix(delta);
    } else {
      delta = level.hardness.attrBounceFix(delta);
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
