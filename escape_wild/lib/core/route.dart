import 'package:escape_wild/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class RouteProtocol with Moddable implements JConvertibleProtocol, RestorationProvider<PlaceProtocol> {
  @override
  String get name;

  RouteProtocol();

  PlaceProtocol get initialPlace;

  Future<void> onPass(TS delta);

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

FireState burningFuel(
  FireState former,
  double cost,
) {
  final curFuel = former.fuel;
  var resFuel = curFuel;
  var resEmber = former.ember;
  if (curFuel <= cost) {
    final costOverflow = cost - curFuel;
    resFuel = 0;
    resEmber += curFuel;
    resEmber -= costOverflow * 2;
  } else {
    resFuel -= cost;
    resEmber += cost;
  }
  return FireState(ember: resEmber, fuel: resFuel);
}

mixin CampfirePlaceMixin implements CampfireHolderProtocol {
  @override
  final $fireState = ValueNotifier<FireState>(FireState.off);

  @fireStateJsonKey
  FireState get fireState => $fireState.value;

  set fireState(FireState v) => $fireState.value = v;

  Future<void> onFirePass(double fuelCostSpeed, TS delta) async {
    final fireState = this.fireState;
    if (fireState.active) {
      final cost = delta / actionTsStep * fuelCostSpeed;
      this.fireState = burningFuel(fireState, cost);
    }
  }

  static const fireStateJsonKey =
      JsonKey(fromJson: fireStateFromJson, toJson: fireStateStackToJson, includeIfNull: false);

  static FireState fireStateFromJson(dynamic json) => json == null ? FireState.off : FireState.fromJson(json);

  static dynamic fireStateStackToJson(FireState fire) => fire.isOff ? null : fire;
}
