import 'package:escape_wild_flutter/core/action.dart';
import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:escape_wild_flutter/core/backpack.dart';
import 'package:flutter/cupertino.dart';

import 'ecs.dart';

class Player with AttributeManagerMixin, ChangeNotifier, ExtraMixin {
  AttrModel _model = const AttrModel();
  Backpack backpack = Backpack();

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
}
