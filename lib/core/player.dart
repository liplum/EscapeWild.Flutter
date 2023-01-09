import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:escape_wild_flutter/core/backpack.dart';
import 'package:flutter/cupertino.dart';

class Player with AttributeManagerMixin, ChangeNotifier {
  AttrModel _model = AttrModel();
  Backpack backpack = Backpack();
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
