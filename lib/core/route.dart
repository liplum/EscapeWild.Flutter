import 'package:escape_wild_flutter/i18n.dart';

import 'action.dart';
import 'player.dart';

abstract class RouteProtocol {
  String get name;

  String get localizedName => I18n["route.$name.name"];

  String get localizedDescription => I18n["route.$name.desc"];
}

abstract class PlaceProtocol {
  String get name;

  String get localizedName;

  String get localizedDescription;

  Future<void> performAction(Player player, ActionType action);

  Set<ActionType> getAvailableActions();
}
