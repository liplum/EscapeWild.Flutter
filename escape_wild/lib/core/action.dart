import 'package:escape_wild/core.dart';

/// Full name: User Action.
///
/// It's to disambiguate with `Action` in flutter.
class UAction with Moddable {
  final UAction? parent;
  @override
  final String name;
  final List<UAction> subActions = [];

  UAction(this.name, {this.parent}) {
    parent?.subActions.add(this);
  }

  /// The sub-action should be in `parent-name.sub-name`.
  UAction sub(String name) => UAction("${this.name}.$name", parent: this);

  factory UAction.named(String name) => UAction(name);

  String l10nName() {
    final parent = this.parent;
    if (parent != null) {
      return i18n("action.$name");
    } else {
      // It's at the top level.
      return i18n("action.$name.name");
    }
  }

  bool belongsToOrSelf(UAction ancestorOrSelf) => this == ancestorOrSelf || belongsTo(ancestorOrSelf);

  bool belongsTo(UAction ancestor) {
    var cur = parent;
    while (cur != null) {
      if (cur == ancestor) return true;
      cur = parent?.parent;
    }
    return false;
  }

  @override
  String toString() => name;

  // Move
  static final UAction move = UAction("move"),
      moveLeft = move.sub("left"),
      moveRight = move.sub("right"),
      moveUp = move.sub("up"),
      moveDown = move.sub("down"),
      moveForward = move.sub("forward"),
      moveBackward = move.sub("backward");
  static final UAction explore = UAction("explore");
  static final UAction gather = UAction("gather"),
      gatherGetWater = gather.sub("get-water"),
      gatherGetWood = gather.sub("get-wood"),
      gatherGetFood = gather.sub("get-food");

  static final UAction shelter = UAction("shelter"),
      shelterSleepTillTomorrow = shelter.sub("sleep-till-tomorrow"),
      shelterReinforce = shelter.sub("reinforce"),
      shelterRest = shelter.sub("rest");
  static final UAction hunt = UAction("hunt"), hunTrap = hunt.sub("trap"), hunGun = hunt.sub("gun");
  static final UAction fish = UAction("fish");

  // Win or lose the game.
  static final UAction escapeWild = UAction("escape-wild"), stopHeartbeat = UAction("stop-heartbeat");

  static final List<UAction> defaultActions = [
    move,
    explore,
    shelter,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UAction || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

extension ActionTypeX on UAction {
  bool get isTopLevel => parent == null;

  bool get isLeaf => subActions.isEmpty;
}
