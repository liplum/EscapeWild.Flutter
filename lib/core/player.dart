import 'package:escape_wild_flutter/core.dart';
import 'package:flutter/cupertino.dart';

class Player with AttributeManagerMixin, ChangeNotifier, ExtraMixin {
  AttrModel _model = const AttrModel();
  Backpack backpack = Backpack();
  Hardness hardness = Hardness.normal;
  var journeyProgress = 0.0;
  late PlaceProtocol location;

  Future<void> performAction(ActionType action) async {}

  @override
  AttrModel get model => _model;

  @override
  set model(AttrModel value) {
    _model = value;
    notifyListeners();
  }

  void loadFromJson(Map<String, dynamic> json) {
    model = AttrModel(
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
