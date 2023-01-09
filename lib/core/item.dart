import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/mod.dart';
import 'package:escape_wild_flutter/i18n.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'attribute.dart';
import 'extra.dart';
import 'player.dart';

part 'item.g.dart';

typedef ItemGetter<T extends ItemMetaProtocol> = T Function();

class _NamedItemGetterImpl<T extends ItemMetaProtocol> {
  final String name;

  const _NamedItemGetterImpl(this.name);

  T get() => Contents.getItemMetaByName(name) as T;
}

_namedItemGetter(String name) => _NamedItemGetterImpl(name).get;

extension NamedItemGetterX on String {
  ItemGetter<T> getAsItem<T extends ItemMetaProtocol>() => _namedItemGetter(this);
}

abstract class ItemMetaProtocol with Moddable {
  ItemMetaProtocol getSelf() => this;

  String get name;

  String get localizedName => I18n["item.$name.name"];

  String get localizedDescription => I18n["item.$name.desc"];
}

String _getItemMetaName(ItemMetaProtocol meta) => meta.name;

class EmptyItemMeta extends ItemMetaProtocol {
  static final EmptyItemMeta instance = EmptyItemMeta._();

  EmptyItemMeta._();

  @override
  String get name => "empty";
}

abstract class ItemProtocol with ExtraMixin implements JConvertibleProtocol {
  @JsonKey(fromJson: Contents.getItemMetaByName, toJson: _getItemMetaName)
  final ItemMetaProtocol meta;

  ItemProtocol(this.meta);

  @override
  int get version => 1;
}

class ItemMeta extends ItemMetaProtocol {
  @override
  final String name;

  ItemMeta(this.name);
}

class Item extends ItemProtocol {
  static const type = "item.Item";

  Item(super.meta);

  @override
  String get typeName => type;
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
  ToolLevel get toolLevel;

  ToolType get toolType;

  double get maxDurability;
}

@JsonSerializable(createToJson: false)
class ToolItemMeta extends ToolItemMetaProtocol {
  @override
  final String name;
  @override
  final ToolLevel toolLevel;
  @override
  final double maxDurability;
  @override
  @JsonKey(fromJson: ToolType.named)
  final ToolType toolType;

  ToolItemMeta(
    this.name, {
    this.toolLevel = ToolLevel.normal,
    required this.toolType,
    required this.maxDurability,
  });

  factory ToolItemMeta.fromJson(Map<String, dynamic> json) => _$ToolItemMetaFromJson(json);
}

@JsonSerializable()
class ToolItem extends ItemProtocol {
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
  @JsonKey()
  final String name;

  @override
  @JsonKey()
  final UseType useType;

  @JsonKey(fromJson: _namedItemGetter)
  final ItemGetter<ItemMetaProtocol>? afterUsedItem;

  AttrModifyItemMeta(
    this.name,
    this.useType,
    this.modifiers, {
    this.afterUsedItem,
  });

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

/// Player can cook the CookableItem in campfire.
/// It will be transformed to another item.
abstract class CookableItemMetaProtocol extends ItemMetaProtocol {
  CookType get cookType;

  ItemMetaProtocol cook();

  double get flueCost;
}

@JsonSerializable(createToJson: false)
class CookableItemMeta extends CookableItemMetaProtocol {
  @override
  @JsonKey()
  final String name;

  @override
  @JsonKey()
  final double flueCost;

  @JsonKey(fromJson: _namedItemGetter)
  final ItemGetter<ItemMetaProtocol> cookOutput;

  @override
  @JsonKey()
  final CookType cookType;

  CookableItemMeta(this.name, this.flueCost, this.cookOutput, this.cookType);

  factory CookableItemMeta.fromJson(Map<String, dynamic> json) => _$CookableItemMetaFromJson(json);

  @override
  ItemMetaProtocol cook() {
    return cookOutput();
  }
}

@JsonSerializable()
class CookableItem extends ItemProtocol {
  static const type = "item.CookableItem";

  CookableItem(super.meta);

  @override
  String get typeName => type;

  factory CookableItem.fromJson(Map<String, dynamic> json) => _$CookableItemFromJson(json);

  Map<String, dynamic> toJson() => _$CookableItemToJson(this);
}

abstract class FuelItemMetaProtocol extends ItemMetaProtocol {
  double get heatValue;
}

@JsonSerializable(createToJson: false)
class FuelItemMeta extends FuelItemMetaProtocol {
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final double heatValue;

  FuelItemMeta(this.name, this.heatValue);

  factory FuelItemMeta.fromJson(Map<String, dynamic> json) => _$FuelItemMetaFromJson(json);
}

@JsonSerializable()
class FuelItem extends ItemProtocol {
  static const type = "item.FuelItem";

  FuelItem(super.meta);

  @override
  String get typeName => type;

  factory FuelItem.fromJson(Map<String, dynamic> json) => _$FuelItemFromJson(json);

  Map<String, dynamic> toJson() => _$FuelItemToJson(this);
}
