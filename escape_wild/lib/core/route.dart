import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';

abstract class RouteProtocol with Moddable implements JConvertibleProtocol, RestorationProvider<PlaceProtocol> {
  @override
  String get name;

  RouteProtocol();

  PlaceProtocol get initialPlace;

  Future<void> onPassTime(Ts delta);

  void onRestored() {}

  String localizedName() => i18n("route.$name.name");

  String localizedDescription() => i18n("route.$name.desc");
}

abstract class PlaceProtocol with ExtraMixin, Moddable implements JConvertibleProtocol {
  @override
  String get name;

  RouteProtocol get route;

  PlaceProtocol();

  String displayName() => localizedName();

  String localizedName() => i18n("route.${route.name}.$name.name");

  String localizedDescription() => i18n("route.${route.name}.$name.desc");

  Future<void> performAction(UAction action);

  List<PlaceAction> getAvailableActions();
}

class PlaceAction {
  final UAction type;
  final bool Function() canPerform;

  const PlaceAction(this.type, this.canPerform);
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

abstract class RouteGeneratorProtocol<T> {
  T generateRoute(RouteGenerateContext ctx, int seed);
}

/// It defines many properties that would affect the game.
extension PlaceProps on PlaceProtocol {
  /// default: 0.0
  static const wetK = "wet";

  double get wet => this[wetK] ?? 0.0;

  set wet(double v) => this[wetK] = v;
}

/// [PlaceActionDelegateMixin] will create delegates for each [UAction].
/// It's easy to provide default behaviors.
mixin PlaceActionDelegateMixin on PlaceProtocol {
  @override
  Future<void> performAction(UAction action) async {
    if (action.belongsToOrSelf(UAction.explore)) {
      await performExplore();
    } else if (action.belongsToOrSelf(UAction.move)) {
      await performMove(action);
    } else if (action.belongsToOrSelf(UAction.gather)) {
      await performGather(action);
    } else if (action.belongsToOrSelf(UAction.fish)) {
      await performFish();
    } else if (action.belongsToOrSelf(UAction.shelter)) {
      await performShelter(action);
    } else if (action.belongsToOrSelf(UAction.hunt)) {
      await performHunt(action);
    } else {
      await performOthers(action);
    }
  }

  Future<void> performExplore() async {}

  Future<void> performMove(UAction action) async {}

  Future<void> performGather(UAction action) async {}

  Future<void> performFish() async {}

  Future<void> performShelter(UAction action) async {}

  Future<void> performHunt(UAction action) async {}

  /// Called when the [action] is not caught by other delegates
  Future<void> performOthers(UAction action) async {}
}
