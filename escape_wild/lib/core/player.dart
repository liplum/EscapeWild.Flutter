import 'dart:convert';
import 'dart:ui';

import 'package:escape_wild/app.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/dialog.dart';
import 'package:escape_wild/game/routes/subtropics.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:noitcelloc/noitcelloc.dart';
import 'package:rettulf/rettulf.dart';

final player = Player();
const polymorphismSave = Object();

/// It will be evaluated at runtime, no need to serialization.
const noSave = Object();

const actionStepTime = Ts(minutes: 5);
const actionDefaultTime = Ts(minutes: 30);
const actionMinTime = Ts.from(minute: 5);
const actionMaxTime = Ts.from(hour: 2);

class Player with AttributeManagerMixin, ChangeNotifier, ExtraMixin {
  AttrModel _attrs = const AttrModel();

  Ratio _journeyProgress = 0.0;

  @noSave
  PlaceProtocol? _location;

  int _actionTimes = 0;

  Color _envColor = const Color(0x00000000);

  Ts _totalTimePassed = Ts.zero;

  @polymorphismSave
  var backpack = Backpack();
  final $isWin = ValueNotifier(false);
  @noSave
  var initialized = false;
  @noSave
  final maxMassLoad = 10000;
  Ts startClock = const Ts.from(hour: 7, minute: 0);

  /// The preference item for each [ToolType].
  /// - If player doesn't select a preferred tool, the tool with highest [ToolAttr] will be selected as default.
  Map<ToolType, int> toolType2ItemIdPref = {};
  var _isExecutingOnPass = false;
  LevelProtocol level = LevelProtocol.empty;

  Future<void> onPassTime(Ts delta) async {
    assert(!_isExecutingOnPass, "$onPassTime can't be nested-called.");
    if (_isExecutingOnPass) return;
    _isExecutingOnPass = true;
    // update multiple times.
    final updateTimes = (delta / actionStepTime).toInt();
    for (var i = 0; i < updateTimes; i++) {
      await level.onPassTime(actionStepTime);
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

  /// When [stack] ends to be tracked, at this point:
  /// - [backpack.mass] was increased by [stack.stackMass].
  /// - [stack.trackId] was allocated.
  /// - [stack] is in [backpack.items].
  ///
  /// If [stack] is merged to existed one, this won't be called.
  void onItemStackAdded(ItemStack stack) {
    var anyChange = false;
    for (final toolComp in ToolComp.of(stack)) {
      final toolType = toolComp.toolType;
      if (!toolType2ItemIdPref.containsKey(toolType)) {
        toolType2ItemIdPref[toolType] = stack.id;
        anyChange = true;
      }
    }
    if (anyChange) {
      notifyListeners();
    }
  }

  /// When [stack] starts to be untracked, at this point:
  /// - [backpack.mass] has not decreased.
  /// - [stack.trackId] has not been set to null.
  /// - [stack] is already removed in [backpack.items].
  void onItemStackRemoved(ItemStack stack) {
    var anyChange = false;
    for (final toolComp in ToolComp.of(stack)) {
      final toolType = toolComp.toolType;
      if (toolType2ItemIdPref.containsValue(stack.id)) {
        toolType2ItemIdPref.remove(toolType);
        anyChange = true;
      }
    }
    if (anyChange) {
      notifyListeners();
    }
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

  bool canPlayerAct() {
    if (isWin) return false;
    if (isDead) return false;
    return true;
  }

  Future<void> onGameWin() async {
    await $context.showTip(
      title: "Congratulation!",
      desc:
          "You win the game after $actionTimes actions and ${totalTimePassed.hourPart} hours ${totalTimePassed.minutePart} minutes.",
      dismissible: false,
      primary: 'OK',
    );
    if ($context.mounted) {
      $context.pop();
    }
  }

  Future<void> onGameFailed() async {
    await $context.showTip(
      title: "YOU DIED",
      desc:
          "Your soul is lost in the wilderness, but you have still tried $actionTimes times and last ${totalTimePassed.hourPart} hours ${totalTimePassed.minutePart} minutes.",
      primary: "Alright",
      dismissible: false,
    );
    if ($context.mounted) {
      $context.pop();
    }
  }

  Future<void> init() async {
    if (initialized) return;
  }

  Future<void> restart() async {
    await init();
    _isExecutingOnPass = false;
    actionTimes = 0;
    envColor = const Color(0x00000000);
    attrs = AttrModel.full;
    backpack.clear();
    totalTimePassed = Ts.zero;
    journeyProgress = 0;
    // Create level.
    final level = SubtropicsLevel();
    this.level = level;
    level.onGenerateRoute();
  }

  bool setToolPref(ToolType toolType, ItemStack stack) {
    toolType2ItemIdPref[toolType] = stack.id;
    notifyListeners();
    return true;
  }

  void clearToolPref(ToolType toolType) {
    if (toolType2ItemIdPref.remove(toolType) != null) {
      notifyListeners();
    }
  }

  ItemStack? getToolPref(ToolType toolType) {
    final itemId = toolType2ItemIdPref[toolType];
    if (itemId == null) return null;
    final stack = backpack.findStackById(itemId);
    assert(stack != null, "$toolType is in $toolType2ItemIdPref but untracked.");
    return stack;
  }

  bool isToolPref(ItemStack stack, ToolType toolType) {
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
    if (toolType2ItemIdPref.containsKey(toolType)) {
      return isToolPref(stack, toolType);
    } else {
      final best = backpack.findToolsOfType(toolType).maxOfOrNull((p) => p.comp.attr);
      return best?.stack == stack;
    }
  }

  void _debugValidate() {
    if (kDebugMode) {
      {
        // check backpack
        for (final stack in backpack) {
          assert(stack.isNotEmpty, "$stack is empty in backpack.");
          if (!stack.meta.mergeable) {
            assert(stack.mass == null, "${stack.meta} is unmergeable but $stack has not-null mass.");
          }
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
                }
                for (final stack in place.offCampfire) {
                  assert(stack.isNotEmpty, "$place has empty offCampfire stack, $stack.");
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
      final backpack = Cvt.fromJsonObj<Backpack>(json["backpack"])!;
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
      this.backpack.loadFrom(backpack);
      this.backpack.validate();
      this.actionTimes = actionTimes;
      this.level = level;
      this.journeyProgress = journeyProgress;
      // ignore: unnecessary_this
      this.toolType2ItemIdPref = toolTypePref;
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
      for (final p in toolType2ItemIdPref.entries) {
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

  void notifyChanges() {
    notifyListeners();
  }

  Ts get totalTimePassed => _totalTimePassed;

  set totalTimePassed(Ts v) {
    _totalTimePassed = v;
    notifyListeners();
  }

  @override
  AttrModel get attrs => _attrs;

  @override
  set attrs(AttrModel v) {
    _attrs = v;
    notifyListeners();
  }

  PlaceProtocol? get location => _location;

  set location(PlaceProtocol? v) {
    _location = v;
    notifyListeners();
  }

  int get actionTimes => _actionTimes;

  set actionTimes(int v) {
    _actionTimes = v;
    notifyListeners();
  }

  Color get envColor => _envColor;

  set envColor(Color v) {
    _envColor = v;
    notifyListeners();
  }

  Ratio get journeyProgress => _journeyProgress;

  set journeyProgress(Ratio v) {
    _journeyProgress = v;
    notifyListeners();
  }
}

extension PlayerX on Player {
  bool get isDead => health <= 0;

  bool get isAlive => !isDead;

  bool get isWin => $isWin.value;

  set isWin(bool v) => $isWin.value = v;

  void modifyX(Attr attr, double delta) {
    if (delta < 0) {
      delta = level.hardness.attrCostFix(delta);
    } else {
      delta = level.hardness.attrBounceFix(delta);
    }
    modify(attr, delta);
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
