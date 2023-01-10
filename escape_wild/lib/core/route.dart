import 'package:escape_wild/core.dart';

abstract class RouteProtocol with Moddable {
  String get name;

  RouteProtocol();

  PlaceProtocol get initialPlace;

  String localizedName() => i18n("route.$name.name");

  String localizedDescription() => i18n("route.$name.desc");
}

abstract class PlaceProtocol with TagsMixin, Moddable {
  String get name;

  RouteProtocol get route;

  PlaceProtocol();

  String displayName() => localizedName();

  String localizedName() => i18n("route.${route.name}.$name.name");

  String localizedDescription() => i18n("route.${route.name}.$name.desc");

  Future<void> performAction(ActionType action);

  Set<ActionType> getAvailableActions();
}

class RouteGenerateContext {
  ModProtocol mod = Vanilla.instance;

  // hardness decides the total journey distance and resource intensity.
  Hardness hardness = Hardness.normal;

  RouteGenerateContext({
    ModProtocol? mod,
    Hardness? hardness,
  }) {
    this.mod = mod ?? Vanilla.instance;
    this.hardness = hardness ?? Hardness.normal;
  }
}

abstract class RouteGeneratorProtocol {
  RouteProtocol generateRoute(RouteGenerateContext ctx);
}

/// It defines many properties that would affect the game.
extension PlaceProps on PlaceProtocol {
  /// default: 0.0
  static const wetK = "wet";

  double get wet => tags[wetK] ?? 0.0;

  set wet(double v) => tags[wetK] = v;
}

mixin PlaceActionDelegateMixin on PlaceProtocol {
  @override
  Future<void> performAction(ActionType action) async {
    if (action == ActionType.explore) {
      await performExplore();
    } else if (action == ActionType.move) {
      await performMove();
    } else if (action == ActionType.cutDownTree) {
      await performCutDownTree();
    } else if (action == ActionType.fish) {
      await performFish();
    } else if (action == ActionType.rest) {
      await performRest();
    } else if (action == ActionType.hunt) {
      await performRest();
    }
  }

  Future<void> performExplore() async {}

  Future<void> performMove() async {}

  Future<void> performCutDownTree() async {}

  Future<void> performFish() async {}

  Future<void> performRest() async {}

  Future<void> performHunt() async {}
}
