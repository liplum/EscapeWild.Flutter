import 'package:escape_wild/core/index.dart';
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

  Future<void> performAction(UserAction action);

  List<PlaceAction> getAvailableActions();
}

class PlaceAction {
  final UserAction type;
  final bool Function() canPerform;

  const PlaceAction(this.type, this.canPerform);
}

class RouteGenerateContext {
  ModProtocol mod = Vanilla.instance;

  // hardness decides the total journey distance and resource intensity.
  Hardness hardness = Hardness.normal;

  RouteGenerateContext({ModProtocol? mod, Hardness? hardness}) {
    this.mod = mod ?? Vanilla.instance;
    this.hardness = hardness ?? .normal;
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

/// [PlaceActionDelegateMixin] will create delegates for each [UserAction].
/// It's easy to provide default behaviors.
mixin PlaceActionDelegateMixin on PlaceProtocol {
  @override
  Future<void> performAction(UserAction action) async {
    if (action == .explore) {
      await performExplore();
    } else if (action == .move) {
      await performMove(action);
    } else if (action == .gather) {
      await performGather(action);
    } else if (action == .fish) {
      await performFish();
    } else if (action == .shelter) {
      await performShelter(action);
    } else if (action == .hunt) {
      await performHunt(action);
    } else {
      await performOthers(action);
    }
  }

  Future<void> performExplore() async {}

  Future<void> performMove(UserAction action) async {}

  Future<void> performGather(UserAction action) async {}

  Future<void> performFish() async {}

  Future<void> performShelter(UserAction action) async {}

  Future<void> performHunt(UserAction action) async {}

  /// Called when the [action] is not caught by other delegates
  Future<void> performOthers(UserAction action) async {}
}
