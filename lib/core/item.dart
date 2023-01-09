import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/i18n.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'attribute.dart';
import 'player.dart';

part 'item.g.dart';

abstract class ItemMetaProtocol {
  const ItemMetaProtocol();

  String get name;

  String get localizedName => I18n["item.$name.name"];

  String get localizedDescription => I18n["item.$name.desc"];
}

String _getItemMetaName(ItemMetaProtocol meta) => meta.name;

class EmptyItemMeta extends ItemMetaProtocol {
  const EmptyItemMeta();

  @override
  String get name => "empty";
}

abstract class Item implements JConvertibleProtocol {
  @JsonKey(fromJson: Contents.getItemMetaByName, toJson: _getItemMetaName)
  final ItemMetaProtocol meta;

  const Item(this.meta);

  @override
  int get version => 1;
}

@JsonEnum()
enum ToolLevel {
  low,
  normal,
  high,
  max;
}

class ToolType {
  final String name;

  const ToolType(this.name);

  factory ToolType.named(String name) => ToolType(name);

  static const ToolType cutting = ToolType("cutting"),
      oxe = ToolType("oxe"),
      hunting = ToolType("hunting"),
      fishing = ToolType("fishing");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ToolType || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

abstract class ToolItemMetaProtocol extends ItemMetaProtocol {
  const ToolItemMetaProtocol();

  ToolLevel get level;

  ToolType get toolType;
}

@JsonSerializable(createToJson: false)
class ToolItemMeta extends ToolItemMetaProtocol {
  @override
  final String name;
  @override
  final ToolLevel level;
  @override
  @JsonKey(fromJson: ToolType.named)
  final ToolType toolType;

  const ToolItemMeta(this.name, this.level, this.toolType);

  factory ToolItemMeta.fromJson(Map<String, dynamic> json) => _$ToolItemMetaFromJson(json);
}

@JsonSerializable()
class ToolItem extends Item {
  static const type = "item.ToolItem";
  @JsonKey()
  double durability = 0.0;

  ToolItem(super.meta);

  @override
  String get typeName => type;

  factory ToolItem.fromJson(Map<String, dynamic> json) => _$ToolItemFromJson(json);

  Map<String, dynamic> toJson() => _$ToolItemToJson(this);
}

@JsonEnum()
enum UseType {
  use,
  drink,
  eat;
}

abstract class UsableItemMetaProtocol extends ItemMetaProtocol {
  const UsableItemMetaProtocol();

  bool canUse(Player player) => true;

  ItemMetaProtocol? afterUsed() => null;

  UseType get useType;

  bool get displayPreview => true;
}

@JsonSerializable(createToJson: false)
class AttrModifyItemMeta extends UsableItemMetaProtocol {
  @JsonKey()
  final List<AttrModifier> modifiers;

  @override
  final String name;

  @override
  final UseType useType;

  const AttrModifyItemMeta(this.name, this.useType, this.modifiers);

  factory AttrModifyItemMeta.fromJson(Map<String, dynamic> json) => _$AttrModifyItemMetaFromJson(json);

  void buildAttrModification(AttrModifierBuilder builder) {
    builder.addAll(modifiers);
  }

  Future<void> use(Player player) async {
    var builder = AttrModifierBuilder();
    buildAttrModification(builder);
    builder.performModification(player);
  }
}

@JsonEnum()
enum CookType {
  cook,
  boil,
  roast;
}
/*

abstract class ICookableItem extends ItemMetaProtocol {
  CookType get cookType;

  /// <summary>
  /// Call this only once.
  /// </summary>
  ItemMetaProtocol cook();

  double get flueCost;
}

abstract class IFuelItem extends ItemMetaProtocol {
  double get fuel;
}
*/
