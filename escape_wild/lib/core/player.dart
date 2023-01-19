import 'dart:convert';

import 'package:escape_wild/app.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/dialog.dart';
import 'package:escape_wild/game/routes/subtropics.dart';
import 'package:flutter/foundation.dart';
import 'package:noitcelloc/noitcelloc.dart';
import 'package:rettulf/rettulf.dart';

final player = Player();
const polymorphismSave = Object();

/// It will be evaluated at runtime, no need to serialization.
const noSave = Object();

const actionTsStep = Ts(minutes: 5);
const maxActionDuration = Ts.from(hour: 2, minute: 0);

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
  static const startClock = Ts.from(hour: 7, minute: 0);
  final $totalTimePassed = ValueNotifier(Ts.zero);
  final $overallActionDuration = ValueNotifier(const Ts(minutes: 30));

  /// The preference item for each [ToolType].
  /// - If player doesn't select a preferred tool, the tool with highest [ToolAttr] will be selected as default.
  Map<ToolType, int> toolType2TrackIdPref = {};
  var _isExecutingOnPass = false;
  LevelProtocol level = LevelProtocol.empty;

  Future<void> onPassTime(Ts delta) async {
    assert(!_isExecutingOnPass, "$onPassTime can't be nested-called.");
    if (_isExecutingOnPass) return;
    _isExecutingOnPass = true;
    // update multiple times.
    final updateTimes = (delta / actionTsStep).toInt();
    for (var i = 0; i < updateTimes; i++) {
      await level.onPassTime(actionTsStep);
    }
    _isExecutingOnPass = false;
    if (kDebugMode) {
      _debugValidate();
    }
  }

  Future<void> performAction(UAction action) {
    assert(!_isExecutingOnPass, "$onPassTime is not ended before $performAction called.");
    if (kDebugMode) {
      _debugValidate();
    }
    return level.performAction(action);
  }

  List<PlaceAction> getAvailableActions() {
    return level.getAvailableActions();
  }

  /// return whether the tool is broken and removed.
  bool damageTool(ItemStack item, ToolComp comp, double damage) {
    comp.damageTool(item, damage);
    if (comp.isBroken(item)) {
      backpack.removeStackInBackpack(item);
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
      desc:
          "You win the game after $actionTimes actions and ${totalTimePassed.hourPart} hours ${totalTimePassed.minutePart} minutes.",
      ok: "OK",
      dismissible: false,
    );
    AppCtx.navigator.pop();
  }

  Future<void> onGameFailed() async {
    await AppCtx.showTip(
      title: "YOU DIED",
      desc:
          "Your soul is lost in the wilderness, but you have still tried $actionTimes times and last ${totalTimePassed.hourPart} hours ${totalTimePassed.minutePart} minutes.",
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

  bool setToolPref(ToolType toolType, ItemStack stack) {
    final trackId = stack.trackId;
    assert(trackId != null, "$stack is in backpack but has no trackId.");
    if (trackId == null) return false;
    toolType2TrackIdPref[toolType] = trackId;
    notifyListeners();
    return true;
  }

  void clearToolPref(ToolType toolType) {
    if (toolType2TrackIdPref.remove(toolType) != null) {
      notifyListeners();
    }
  }

  void _debugValidate() {
    if (kDebugMode) {
      {
        // check backpack
        final backpackSumMass = backpack.sumMass();
        assert(backpack.mass == backpack.sumMass(), "Sum[$backpackSumMass] != State[${backpack.mass}]");
        for (final stack in backpack) {
          assert(stack.isNotEmpty, "$stack is empty in backpack.");
          if (!stack.meta.mergeable) {
            assert(stack.mass == null, "${stack.meta} is unmergeable but $stack has not-null mass.");
          }
          assert(stack.trackId != null, "$stack in backpack has a null trackId");
        }
      }
      {
        // check route
        final loc = location;
        if (loc != null) {
          final route = loc.route;
          final locRestoreId = loc.route.getRestoreIdOf(loc);
          assert(loc.route.restoreById(locRestoreId) == loc);
          if (route is Iterable<PlaceProtocol>) {
            for (final place in route as Iterable<PlaceProtocol>) {
              assert(place.route == route, "${place.route} and $place must be matched.");
              if (place is CampfirePlaceProtocol) {
                for (final stack in place.onCampfire) {
                  assert(stack.isNotEmpty, "$place has empty onCampfire stack, $stack");
                  assert(stack.trackId == null, "$stack on campfire has a not-null trackId[${stack.trackId}]");
                }
                for (final stack in place.offCampfire) {
                  assert(stack.isNotEmpty, "$place has empty offCampfire stack, $stack.");
                  assert(stack.trackId == null, "$stack on campfire has a not-null trackId[${stack.trackId}]");
                }
              }
            }
          }
        }
      }
    }
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
      final toolTypePref = <ToolType, int>{};
      for (final p in (json["toolTypePref"] as Map<String, dynamic>).entries) {
        toolTypePref[ToolType(p.key)] = (p.value as num).toInt();
      }
      level.onRestore();
      // set fields
      this.attrs = attrs;
      this.backpack.loadFrom(backpack!);
      this.backpack.validate();
      this.actionTimes = actionTimes;
      this.level = level;
      this.journeyProgress = journeyProgress;
      // ignore: unnecessary_this
      this.toolType2TrackIdPref = toolTypePref;
      // ignore: unnecessary_this
      this.location = lastLocation;
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
    {
      final map = <String, int>{};
      for (final p in toolType2TrackIdPref.entries) {
        map[p.key.name] = p.value;
      }
      json["toolTypePref"] = map;
    }
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

  Ts get overallActionDuration => $overallActionDuration.value;

  set overallActionDuration(Ts v) => $overallActionDuration.value = v;

  Ts get totalTimePassed => $totalTimePassed.value;

  set totalTimePassed(Ts v) => $totalTimePassed.value = v;

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

  ItemStack? getToolPref(ToolType toolType) {
    final trackId = toolType2TrackIdPref[toolType];
    if (trackId == null) return null;
    final stack = backpack.findStackByTrackId(trackId);
    // remove pref if trackId is no longer valid.
    if (stack == null) {
      toolType2TrackIdPref.remove(toolType);
      return null;
    }
    return stack;
  }

  bool isToolPref(ItemStack stack, ToolType toolType) {
    assert(stack.trackId != null, "$stack has a null trackId");
    assert(() {
      for (final comp in stack.meta.getCompsOf<ToolComp>()) {
        if (comp.toolType == toolType) {
          return true;
        }
      }
      return false;
    }(), "$stack is not a tool[$toolType].");
    return getToolPref(toolType) == stack;
  }

  bool isToolPrefOrDefault(ItemStack stack, ToolType toolType) {
    if (toolType2TrackIdPref.containsKey(toolType)) {
      return isToolPref(stack, toolType);
    } else {
      final best = backpack.findToolsOfType(toolType).maxOfOrNull((p) => p.comp.attr);
      return best?.stack == stack;
    }
  }

  ItemCompPair<ToolComp>? findBestToolOfType(ToolType toolType) {
    final pref = getToolPref(toolType);
    if (pref != null) {
      final comp = ToolComp.ofType(pref, toolType);
      if (comp != null) {
        return ItemCompPair<ToolComp>(pref, comp);
      }
    }
    return backpack.findToolsOfType(toolType).maxOfOrNull((p) => p.comp.attr);
  }
}

class GameSaveCorruptedError implements Exception {
  final Object cause;
  final StackTrace stacktrace;

  const GameSaveCorruptedError(this.cause, this.stacktrace);

  @override
  String toString() => "$cause";
}
