import 'package:escape_wild_flutter/core/content.dart';
import 'package:escape_wild_flutter/core/mod.dart';
import 'package:escape_wild_flutter/i18n.dart';
import 'package:escape_wild_flutter/utils/enum.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'attribute.dart';
import 'extra.dart';
import 'player.dart';

part 'item.g.dart';

typedef ItemGetter<T extends Item> = T Function();

class _NamedItemGetterImpl<T extends Item> {
  final String name;

  const _NamedItemGetterImpl(this.name);

  T get() => Contents.getItemMetaByName(name) as T;
}

_namedItemGetter(String name) => _NamedItemGetterImpl(name).get;

extension NamedItemGetterX on String {
  ItemGetter<T> getAsItem<T extends Item>() => _namedItemGetter(this);
}

@JsonSerializable(createToJson: false)
class Item with Moddable {
  static final empty = Item("empty");
  final String name;
  @JsonKey(toJson: directConvertFunc)
  final Map<Type, ItemComp> components = {};

  Item(this.name);

  Item self() => this;

  String get localizedName => I18n["item.${mod.decorateRegisterName(name)}.name"];

  String get localizedDescription => I18n["item.${mod.decorateRegisterName(name)}.desc"];

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

extension ItemMetaProtocolX<TItem extends Item> on TItem {
  TItem addCompOfType<T extends ItemComp>(Type type, T comp) {
    components[type] = comp;
    return this;
  }

  TItem addCompOfExactType<T extends ItemComp>(T comp) {
    components[T] = comp;
    return this;
  }

  TItem addCompOfExactTypes(Iterable<Type> types, ItemComp comp) {
    for (final type in types) {
      components[type] = comp;
    }
    return this;
  }

  T? tryGetComp<T extends ItemComp>() {
    return components[T] as T?;
  }

  T getComp<T extends ItemComp>() {
    return components[T] as T;
  }

  bool hasComp<T extends ItemComp>() {
    return components.containsKey(T);
  }

  T? getCompOfTypes<T extends ItemComp>(Iterable<Type> types) {
    ItemComp? comp;
    for (final type in types) {
      final found = components[type];
      if (found == null || found is! T) {
        return null;
      } else {
        comp = found;
      }
    }
    return comp as T?;
  }
}

class CompPair<T extends ItemComp> {
  final ItemEntry item;
  final T comp;

  const CompPair(this.item, this.comp);
}

@JsonSerializable()
class ItemEntry with ExtraMixin implements JConvertibleProtocol {
  @JsonKey(fromJson: Contents.getItemMetaByName, toJson: _getItemMetaName)
  final Item meta;
  static const type = "Item";

  ItemEntry(this.meta);

  @override
  String get typeName => type;

  factory ItemEntry.fromJson(Map<String, dynamic> json) => _$ItemEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ItemEntryToJson(this);
}

extension ItemEntryX on ItemEntry {
  String get name => meta.name;

  T? tryGetComp<T extends ItemComp>() => meta.tryGetComp<T>();

  T getComp<T extends ItemComp>() => meta.getComp<T>();

  bool hasComp<T extends ItemComp>() => meta.hasComp<T>();
}

abstract class ItemComp implements JConvertibleProtocol {
  const ItemComp();
}

class _EmptyComp extends ItemComp {
  static const type = "Empty";

  @override
  String get typeName => type;
}

String _getItemMetaName(Item meta) => meta.name;

@JsonEnum()
enum ToolLevel with EnumCompareByIndexMixin {
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
      trap = ToolType("trap"),
      gun = ToolType("gun"),
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

@JsonSerializable(createToJson: false)
class ToolComp extends ItemComp {
  @JsonKey()
  final ToolLevel toolLevel;
  @JsonKey()
  final double maxDurability;
  @JsonKey(fromJson: ToolType.named)
  final ToolType toolType;

  ToolComp({
    this.toolLevel = ToolLevel.normal,
    required this.toolType,
    required this.maxDurability,
  });

  double getDurability(ItemEntry item) => item["Tool.durability"] ?? 0.0;

  void setDurability(ItemEntry item, double value) => item["Tool.durability"] = value;

  factory ToolComp.fromJson(Map<String, dynamic> json) => _$ToolCompFromJson(json);
  static const type = "Tool";

  @override
  String get typeName => type;
}

extension ToolCompX on Item {
  Item asTool({
    required ToolType type,
    ToolLevel level = ToolLevel.normal,
    required double maxDurability,
  }) {
    return addCompOfExactType<ToolComp>(ToolComp(
      toolLevel: level,
      toolType: type,
      maxDurability: maxDurability,
    ));
  }
}

@JsonEnum()
enum UseType {
  use,
  drink,
  eat;
}

abstract class UsableItemComp extends ItemComp {
  @JsonKey()
  final UseType useType;

  UsableItemComp(this.useType);

  bool canUse(Player player) => true;

  Future<void> onUse(Player player) async {}

  bool get displayPreview => true;
  static const type = "Usable";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class ModifyAttrComp extends UsableItemComp {
  @JsonKey()
  final List<AttrModifier> modifiers;
  @JsonKey(fromJson: _namedItemGetter)
  final ItemGetter<Item>? afterUsedItem;

  ModifyAttrComp(
    super.useType,
    this.modifiers, {
    this.afterUsedItem,
  });

  factory ModifyAttrComp.fromJson(Map<String, dynamic> json) => _$ModifyAttrCompFromJson(json);

  void buildAttrModification(AttrModifierBuilder builder) {
    builder.addAll(modifiers);
  }

  @override
  Future<void> onUse(Player player) async {
    var builder = AttrModifierBuilder();
    buildAttrModification(builder);
    builder.performModification(player);
  }

  static const type = "AttrModify";

  @override
  String get typeName => type;
}

extension ModifyAttrCompX on Item {
  Item modifyAttr(
    UseType useType,
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsedItem,
  }) {
    return addCompOfExactType<UsableItemComp>(ModifyAttrComp(
      useType,
      modifiers,
      afterUsedItem: afterUsedItem,
    ));
  }

  Item asEatable(
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsedItem,
  }) {
    return addCompOfExactType<UsableItemComp>(ModifyAttrComp(
      UseType.eat,
      modifiers,
      afterUsedItem: afterUsedItem,
    ));
  }

  Item asUsable(
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsedItem,
  }) {
    return addCompOfExactType<UsableItemComp>(ModifyAttrComp(
      UseType.use,
      modifiers,
      afterUsedItem: afterUsedItem,
    ));
  }

  Item asDrinkable(
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsed,
  }) {
    return addCompOfExactType<UsableItemComp>(ModifyAttrComp(
      UseType.drink,
      modifiers,
      afterUsedItem: afterUsed,
    ));
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
@JsonSerializable(createToJson: false)
class CookableComp extends ItemComp {
  @JsonKey()
  final CookType cookType;
  @JsonKey()
  final double flueCost;
  @JsonKey(fromJson: _namedItemGetter)
  final ItemGetter<Item> cookedOutput;

  CookableComp(this.cookType, this.flueCost, this.cookedOutput);

  static const type = "Cookable";

  @override
  String get typeName => type;

  factory CookableComp.fromJson(Map<String, dynamic> json) => _$CookableCompFromJson(json);
}

extension CookableCompX on Item {
  Item asCookable(
    CookType cookType, {
    required double fuelCost,
    required ItemGetter<Item> output,
  }) {
    return addCompOfExactType<CookableComp>(
      CookableComp(cookType, fuelCost, output),
    );
  }
}

@JsonSerializable(createToJson: false)
class FuelComp extends ItemComp {
  @JsonKey()
  final double heatValue;

  FuelComp(this.heatValue);

  static const type = "Fuel";

  @override
  String get typeName => type;

  factory FuelComp.fromJson(Map<String, dynamic> json) => _$FuelCompFromJson(json);
}

extension FuelCompX on Item {
  Item asFuel({required double heatValue}) {
    return addCompOfExactType<FuelComp>(
      FuelComp(heatValue),
    );
  }
}
