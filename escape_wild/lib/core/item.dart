import 'package:escape_wild/core.dart';
import 'package:escape_wild/utils/enum.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

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

class Item with Moddable, CompMixin<ItemComp> {
  static final empty = Item("empty");
  final String name;

  /// If mass is more than 0, it means the item is unmergeable.
  /// Unit: [g] gram
  final double? mass;

  Item(this.name, {this.mass});

  Item.unmergeable(this.name, {required this.mass});

  Item.mergeable(this.name) : mass = null;

  Item self() => this;

  String get localizedName => i18n("item.$name.name");

  String get localizedDescription => i18n("item.$name.desc");
}

extension ItemX on Item {
  bool get mergeable => mass == null;
}

class ItemMergeableCompConflictError implements Exception {
  final String message;
  final Item item;
  final bool mergeableShouldBe;

  const ItemMergeableCompConflictError(
    this.message,
    this.item, {
    required this.mergeableShouldBe,
  });

  @override
  String toString() => "[${item.name}]$message";
}

class ItemCompConflictError implements Exception {
  final String message;
  final Item item;
  final Comp conflictWith;

  const ItemCompConflictError(this.message, this.item, this.conflictWith);
}

abstract class ItemComp extends Comp {
  void validateItemConfig(Item item) {}

  void onMerge(ItemEntry from, ItemEntry to) {}
}

class ItemCompPair<T extends Comp> {
  final ItemEntry item;
  final T comp;

  const ItemCompPair(this.item, this.comp);
}

@JsonSerializable()
class ItemEntry with ExtraMixin implements JConvertibleProtocol {
  @JsonKey(fromJson: Contents.getItemMetaByName, toJson: _getItemMetaName)
  final Item meta;
  static const type = "Item";
  @JsonKey(includeIfNull: false)
  double? mass;

  ItemEntry(
    this.meta, {
    this.mass,
  });

  @override
  String get typeName => type;

  bool hasIdenticalMeta(ItemEntry other) => meta == other.meta;

  void mergeTo(ItemEntry to) {
    if (!meta.mergeable) {
      throw MergeNotAllowedError("${meta.name} is not mergeable.", meta);
    }
    final selfMass = mass ?? 0.0;
    final toMass = to.mass ?? 0.0;
    if (!hasIdenticalMeta(to)) {
      throw MergeNotAllowedError("Can't merge ${meta.name} with ${to.meta}.", meta);
    }
    for (final comp in meta.iterateComps()) {
      comp.onMerge(this, to);
    }
    to.mass = selfMass + toMass;
  }

  factory ItemEntry.fromJson(Map<String, dynamic> json) => _$ItemEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ItemEntryToJson(this);
}

class MergeNotAllowedError implements Exception {
  final String message;
  final Item item;

  const MergeNotAllowedError(this.message, this.item);

  @override
  String toString() => "[${item.name}]$message";
}

extension ItemEntryX on ItemEntry {
  double? tryGetActualMass() => meta.mass ?? mass;

  double getActualMassOr([double fallback = 0.0]) => meta.mass ?? mass ?? fallback;
}

class EmptyComp extends Comp {
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

  @override
  void validateItemConfig(Item item) {
    if (item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$ToolComp doesn't conform to mergeable item.",
        item,
        mergeableShouldBe: false,
      );
    }
  }

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
    final comp = ToolComp(
      toolLevel: level,
      toolType: type,
      maxDurability: maxDurability,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
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

  bool canUse() => true;

  Future<void> onUse() async {}

  bool get displayPreview => true;
  static const type = "Usable";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class ModifyAttrComp extends UsableItemComp {
  @override
  Type get compType => UsableItemComp;
  @JsonKey()
  final List<AttrModifier> modifiers;
  @JsonKey(fromJson: _namedItemGetter)
  final ItemGetter<Item>? afterUsedItem;
  @JsonKey(includeIfNull: true)
  final double? modifierUnit;

  ModifyAttrComp(
    super.useType,
    this.modifiers, {
    this.modifierUnit,
    this.afterUsedItem,
  });

  factory ModifyAttrComp.fromJson(Map<String, dynamic> json) => _$ModifyAttrCompFromJson(json);

  void buildAttrModification(AttrModifierBuilder builder) {
    builder.addAll(modifiers);
  }

  @override
  Future<void> onUse() async {
    var builder = AttrModifierBuilder();
    buildAttrModification(builder);
    builder.performModification(player);
  }

  static const type = "AttrModify";

  @override
  String get typeName => type;

  @override
  void validateItemConfig(Item item) {
    if (modifierUnit == null && item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$ModifyAttrComp requires `unit` in mergeable.",
        item,
        mergeableShouldBe: false,
      );
    }
    if (modifierUnit != null && !item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$ModifyAttrComp doesn't allow `unit` in unmergeable.",
        item,
        mergeableShouldBe: true,
      );
    }
  }
}

extension ModifyAttrCompX on Item {
  Item modifyAttr(
    UseType useType,
    List<AttrModifier> modifiers, {
    double? unit,
    ItemGetter<Item>? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      useType,
      modifiers,
      modifierUnit: unit,
      afterUsedItem: afterUsed,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }

  Item asEatable(
    List<AttrModifier> modifiers, {
    double? unit,
    ItemGetter<Item>? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.eat,
      modifiers,
      modifierUnit: unit,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }

  Item asUsable(
    List<AttrModifier> modifiers, {
    double? unit,
    ItemGetter<Item>? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.use,
      modifiers,
      modifierUnit: unit,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }

  Item asDrinkable(
    List<AttrModifier> modifiers, {
    double? unit,
    ItemGetter<Item>? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      UseType.drink,
      modifiers,
      modifierUnit: unit,
      afterUsedItem: afterUsed,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
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
  final double fuelCost;
  @JsonKey(fromJson: _namedItemGetter)
  final ItemGetter<Item> cookedOutput;
  @JsonKey()
  final double? fuelCostUnit;

  CookableComp(
    this.cookType,
    this.fuelCost,
    this.cookedOutput, {
    this.fuelCostUnit,
  });

  @override
  void validateItemConfig(Item item) {
    if (fuelCostUnit == null && item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$CookableComp requires `unit` in mergeable.",
        item,
        mergeableShouldBe: false,
      );
    }
    if (fuelCostUnit != null && !item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$CookableComp doesn't allow `unit` in unmergeable.",
        item,
        mergeableShouldBe: true,
      );
    }
  }

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
    double? unit,
  }) {
    final comp = CookableComp(
      cookType,
      fuelCost,
      output,
      fuelCostUnit: unit,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

@JsonSerializable(createToJson: false)
class FuelComp extends ItemComp {
  @JsonKey()
  final double heatValue;
  @JsonKey(includeIfNull: true)
  final double? fuelUnit;

  FuelComp(
    this.heatValue, {
    this.fuelUnit,
  });

  @override
  void validateItemConfig(Item item) {
    if (fuelUnit == null && item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$FuelComp requires `unit` in mergeable.",
        item,
        mergeableShouldBe: false,
      );
    }
    if (fuelUnit != null && !item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$FuelComp doesn't allow `unit` in unmergeable.",
        item,
        mergeableShouldBe: true,
      );
    }
  }

  static const type = "Fuel";

  @override
  String get typeName => type;

  factory FuelComp.fromJson(Map<String, dynamic> json) => _$FuelCompFromJson(json);
}

extension FuelCompX on Item {
  Item asFuel({
    required double heatValue,
    double? unit,
  }) {
    final comp = FuelComp(
      heatValue,
      fuelUnit: unit,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

class WetComp extends ItemComp {
  static const _wetK = "Wet.wet";

  Ratio getWet(ItemEntry item) => item[_wetK] ?? 0.0;

  void setWet(ItemEntry item, Ratio value) => item[_wetK] = value;

  @override
  void onMerge(ItemEntry from, ItemEntry to) {
    if (!from.hasIdenticalMeta(to)) return;
    final fromMass = from.getActualMassOr();
    final toMass = to.getActualMassOr();
    final fromWet = getWet(from) * fromMass;
    final toWet = getWet(to) * toMass;
    final average = (fromWet + toWet) / (fromMass + toMass);
    setWet(to, average);
  }

  static const type = "Wet";

  @override
  String get typeName => "Wet";
}

class FreshnessComp extends ItemComp {
  static const _freshnessK = "Freshness.freshness";

  Ratio geFreshness(ItemEntry item) => item[_freshnessK] ?? 1.0;

  void setFreshness(ItemEntry item, Ratio value) => item[_freshnessK] = value;

  @override
  void onMerge(ItemEntry from, ItemEntry to) {
    if (!from.hasIdenticalMeta(to)) return;
    final fromMass = from.getActualMassOr();
    final toMass = to.getActualMassOr();
    final fromFreshness = geFreshness(from) * fromMass;
    final toFreshness = geFreshness(to) * toMass;
    final average = (toFreshness + fromFreshness) / (fromMass + toMass);
    setFreshness(to, average);
  }

  static const type = "Freshness";

  @override
  String get typeName => type;
}
