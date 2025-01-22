import 'package:escape_wild/core/index.dart';

/// Full name: User Action.
///
/// It's to disambiguate with `Action` in flutter.
class UserAction with Moddable {
  final UserAction? parent;
  @override
  final String name;
  final List<UserAction> subActions = [];

  UserAction(this.name, {this.parent}) {
    parent?.subActions.add(this);
  }

  /// The sub-action should be in `parent-name.sub-name`.
  UserAction sub(String name) => UserAction("${this.name}.$name", parent: this);

  factory UserAction.named(String name) => UserAction(name);

  String l10nName() {
    final parent = this.parent;
    if (parent != null) {
      return i18n("action.$name");
    } else {
      // It's at the top level.
      return i18n("action.$name.name");
    }
  }

  bool belongsToOrSelf(UserAction ancestorOrSelf) => this == ancestorOrSelf || belongsTo(ancestorOrSelf);

  bool belongsTo(UserAction ancestor) {
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
  static final //
      move = UserAction("move"),
      moveLeft = move.sub("left"),
      moveRight = move.sub("right"),
      moveUp = move.sub("up"),
      moveDown = move.sub("down"),
      moveForward = move.sub("forward"),
      moveBackward = move.sub("backward");
  static final //
      explore = UserAction("explore");
  static final //
      gather = UserAction("gather"),
      gatherGetWater = gather.sub("get-water"),
      gatherGetWood = gather.sub("get-wood"),
      gatherGetFood = gather.sub("get-food");

  static final //
      shelter = UserAction("shelter"),
      shelterSleepTillTomorrow = shelter.sub("sleep-till-tomorrow"),
      shelterReinforce = shelter.sub("reinforce"),
      shelterRest = shelter.sub("rest");

  static final //
      campfire = UserAction("campfire");
  static final //
      hunt = UserAction("hunt"),
      hunTrap = hunt.sub("trap"),
      hunGun = hunt.sub("gun");
  static final //
      fish = UserAction("fish");

  // Win or lose the game.
  static final escapeWild = UserAction("escape-wild"), stopHeartbeat = UserAction("stop-heartbeat");

  static final List<UserAction> defaultActions = [
    move,
    explore,
    shelter,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserAction || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

extension UActionX on UserAction {
  bool get isTopLevel => parent == null;

  bool get isLeaf => subActions.isEmpty;
}
