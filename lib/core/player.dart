import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable(createFactory: false)
class Player with AttributeManagerMixin, DefaultAttrModelMixin, ChangeNotifier {
  @override
  @JsonKey(ignore: true)
  AttrModelProtocol get model => this;

  void loadFromJson(Map<String, dynamic> json) {
    health = json["health"];
    water = json["water"];
    food = json["food"];
    energy = json["energy"];
    notifyListeners();
  }
}
