import 'package:escape_wild_flutter/i18n.dart';

import 'attribute.dart';
import 'player.dart';

abstract class IItem {
  String get name;

  String get localizedName => I18n["item.$name.name"];

  String get localizedDescription => I18n["item.$name.desc"];
}

enum ToolLevel {
  low,
  normal,
  high,
  max;
}

class ToolType {
  final String name;

  const ToolType(this.name);

  static const ToolType cutting = ToolType("Cutting"),
      oxe = ToolType("Oxe"),
      hunting = ToolType("Hunting"),
      fishing = ToolType("Fishing");
}

abstract class IToolItem extends IItem {
  ToolLevel get level;

  ToolType get toolType;

  double get durability;

  set durability(double value);
}

enum UseType {
  use,
  drink,
  eat;
}

abstract class IUsableItem extends IItem {
  void buildAttrModification(AttrModifierBuilder builder);

  bool canUse(Player player) => true;

  Future<void> use(Player player) async {
    var builder = AttrModifierBuilder();
    buildAttrModification(builder);
    builder.performModification(player);
  }

  IItem? afterUsed() => null;

  UseType get useType;

  bool get displayPreview => true;
}

enum CookType {
  cook,
  boil,
  roast;
}

abstract class ICookableItem extends IItem {
  CookType get cookType;

  /// <summary>
  /// Call this only once.
  /// </summary>
  IItem cook();

  double get flueCost;
}

abstract class IFuelItem extends IItem {
  double get fuel;
}
