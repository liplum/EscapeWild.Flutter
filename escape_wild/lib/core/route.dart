import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';

abstract class RouteProtocol with Moddable implements JConvertibleProtocol {
  String get name;

  RouteProtocol();

  PlaceProtocol get initialPlace;

  /// Return an restore id to save current place.
  dynamic getPlaceRestoreId(PlaceProtocol place);

  /// Resolve [restoreId] to one of this places.
  PlaceProtocol restorePlaceById(dynamic restoreId);

  String localizedName() => i18n("route.$name.name");

  String localizedDescription() => i18n("route.$name.desc");
}

abstract class PlaceProtocol with ExtraMixin, Moddable implements JConvertibleProtocol {
  String get name;

  RouteProtocol get route;

  PlaceProtocol();

  String displayName() => localizedName();

  String localizedName() => i18n("route.${route.name}.$name.name");

  String localizedDescription() => i18n("route.${route.name}.$name.desc");

  Future<void> performAction(ActionType action);

  List<PlaceAction> getAvailableActions();
}

class PlaceAction {
  final ActionType type;
  final bool Function() canPerform;

  const PlaceAction(this.type, this.canPerform);

  static final moveWithEnergy = PlaceAction(ActionType.move, () => player.energy > 0.0);
  static final exploreWithEnergy = PlaceAction(ActionType.explore, () => player.energy > 0.0);
  static final huntWithTool = PlaceAction(
    ActionType.hunt,
    () => player.backpack.hasAnyToolOfTypes([
      ToolType.trap,
      ToolType.gun,
    ]),
  );
  static final fishWithTool = PlaceAction(
    ActionType.fish,
    () => player.backpack.hasAnyToolOfType(ToolType.fishing),
  );
  static final cutDownTreeWithTool = PlaceAction(
    ActionType.cutDownTree,
    () => player.backpack.hasAnyToolOfType(ToolType.axe),
  );
  static final rest = PlaceAction(ActionType.rest, () => true);
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
  RouteProtocol generateRoute(RouteGenerateContext ctx, int seed);
}

/// It defines many properties that would affect the game.
extension PlaceProps on PlaceProtocol {
  /// default: 0.0
  static const wetK = "wet";

  double get wet => this[wetK] ?? 0.0;

  set wet(double v) => this[wetK] = v;
}

/// [PlaceActionDelegateMixin] will create delegates for each [ActionType].
/// It's easy to provide default behaviors.
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
      await performHunt();
    }
  }

  Future<void> performExplore() async {}

  Future<void> performMove() async {}

  Future<void> performCutDownTree() async {}

  Future<void> performFish() async {}

  Future<void> performRest() async {}

  Future<void> performHunt() async {}
}
