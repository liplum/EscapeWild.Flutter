import 'package:escape_wild/core.dart';
import 'package:escape_wild/game/route/subtropics.dart';
import 'package:flutter/cupertino.dart';

class Player with AttributeManagerMixin, ChangeNotifier, ExtraMixin {
  final $attrs = ValueNotifier(const AttrModel());
  var backpack = Backpack();
  var hardness = Hardness.normal;
  final $journeyProgress = ValueNotifier<Progress>(0.0);
  final $location = ValueNotifier<PlaceProtocol?>(null);
  RouteProtocol? route;

  Future<void> performAction(ActionType action) async {
    await location?.performAction(action);
  }

  Future<void> init() async {
    final generator = SubtropicsRouteGenerator();
    final ctx = RouteGenerateContext(hardness: hardness);
    final generatedRoute = generator.generateRoute(ctx);
    route = generatedRoute;
    location = generatedRoute.initialPlace;
  }

  Future<void> restart() async {}

  PlaceProtocol? get location => $location.value;

  set location(PlaceProtocol? v) => $location.value = v;

  @override
  AttrModel get attrs => $attrs.value;

  @override
  set attrs(AttrModel value) {
    $attrs.value = value;
    notifyListeners();
  }

  double get journeyProgress => $journeyProgress.value;

  set journeyProgress(double v) => $journeyProgress.value = v;

  void loadFromJson(Map<String, dynamic> json) {
    attrs = AttrModel(
      health: json["health"],
      water: json["water"],
      food: json["food"],
      energy: json["energy"],
    );

    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      "health": health,
      "water": water,
      "food": food,
      "energy": energy,
    };
  }
}

extension PlayerX on Player {
  bool get isDead => health <= 0;

  bool get isAlive => !isDead;

  void modifyX(Attr attr, double delta) {
    if (delta < 0) {
      delta = hardness.attrCostFix(delta);
    } else {
      delta = hardness.attrBounceFix(delta);
    }
    modify(attr, delta);
  }
}