import 'package:escape_wild/core/index.dart';

/// It's to disambiguate with `Action` in flutter.
class UserAction with Moddable {
  @override
  final String name;

  UserAction(this.name);

  String l10nName() => i18n("action.$name");

  factory UserAction.named(String name) => UserAction(name);

  @override
  String toString() => name;

  // Move
  static final //
      move = UserAction("move"),
      explore = UserAction("explore"),
      gather = UserAction("gather"),
      getWood = UserAction("get-wood"),
      getWater = UserAction("get-water"),
      getFood = UserAction("get-food"),
      shelter = UserAction("shelter"),
      campfire = UserAction("campfire"),
      hunt = UserAction("hunt"),
      fish = UserAction("fish");

  static final
      // Win the game
      escapeWild = UserAction("escape-wild"),
      // Lose the game
      stopHeartbeat = UserAction("stop-heartbeat");

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
