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
  static final empty = Item("empty", mergeable: true, mass: 0);
  final String name;

  /// ## When [mergeable] is false
  /// It means the item is unmergeable, and [mass] is for one ItemEntry.
  /// ### Example
  /// [mass] of `Tinned Tomatoes` is 500. So each ItemEntry takes 500g room in backpack.
  /// When player eat or cook it, if possible, [ModifyAttrComp.modifiers] and [CookableComp.fuelCost] will apply full changes.
  /// ## When [mergeable] is true
  /// It means the item is mergeable, and [mass] is the unit for each ItemEntry.
  /// ### Example
  /// [mass] of `Berry` is 10. However, ItemEntry doesn't care that, it could have an independent [ItemEntry.mass] instead.
  /// When player eat or cook it, [ModifyAttrComp.modifiers] and [CookableComp.fuelCost] will apply changes based [ItemEntry.mass].
  /// If [ItemEntry.mass] is 25, and player has eaten 15g, then [ModifyAttrComp.modifiers] will apply `(15.0 / 10.0) * modifier`.
  /// Unit: [g] gram
  final int mass;
  final bool mergeable;

  Item(this.name, {required this.mergeable, required this.mass});

  Item.unmergeable(this.name, {required this.mass}) : mergeable = false;

  Item.mergeable(this.name, {required this.mass}) : mergeable = true;

  Item self() => this;

  String localizedName() => i18n("item.$name.name");

  String localizedDescription() => i18n("item.$name.desc");
}

extension ItemX on Item {
  ItemEntry create({int? mass, double? massF}) {
    if (mergeable) {
      assert(mass != null || massF != null, "`mass` and `massFactor` can't be both null for mergeable");
      if (mass != null) {
        return ItemEntry(this, mass: mass);
      }
      if (massF != null) {
        return ItemEntry(this, mass: (this.mass * massF).toInt());
      }
      // should not be reached.
      return ItemEntry(this, mass: this.mass);
    } else {
      assert(mass == null && massF == null, "`mass` and `massFactor` should be both null for unmergeable");
      return ItemEntry(this);
    }
  }

  List<ItemEntry> repeat(int number) {
    assert(number > 0, "`number` should be over than 0.");
    assert(!mergeable, "only unmergeable can be generated repeatedly.");
    if (mergeable) {
      return [];
    } else {
      return List.generate(number.abs(), (i) => ItemEntry(this));
    }
  }
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

  const ItemCompConflictError(this.message, this.item);
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
  int? mass;

  ItemEntry(
    this.meta, {
    this.mass,
  });

  @override
  String get typeName => type;

  bool hasIdenticalMeta(ItemEntry other) => meta == other.meta;

  @override
  String toString() {
    final m = mass;
    final name = meta.localizedName();
    if (m == null) {
      return name;
    } else {
      return "$name ${m.toStringAsFixed(1)}g";
    }
  }

  void mergeTo(ItemEntry to) {
    if (!meta.mergeable) {
      throw MergeNotAllowedError("${meta.name} is not mergeable.", meta);
    }
    final selfMass = actualMass;
    final toMass = to.actualMass;
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
  int get actualMass => mass ?? meta.mass;

  double get massMultiplier => actualMass / meta.mass;

  bool canMergeTo(ItemEntry to) {
    return hasIdenticalMeta(to) && meta.mergeable;
  }
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

  static const ToolType cutting = ToolType("cutting");
  /// Use to cut down tree
  static const ToolType oxe = ToolType("oxe");

  /// Use to hunt
  static const ToolType trap = ToolType("trap");

  /// Use to hunt
  static const ToolType gun = ToolType("gun");
  /// Use to fish
  static const ToolType fishing = ToolType("fishing");

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

  Future<void> onUse(ItemEntry item) async {}

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

  ModifyAttrComp(
    super.useType,
    this.modifiers, {
    this.afterUsedItem,
  });

  factory ModifyAttrComp.fromJson(Map<String, dynamic> json) => _$ModifyAttrCompFromJson(json);

  void buildAttrModification(ItemEntry item, AttrModifierBuilder builder) {
    if (item.meta.mergeable) {
      for (final modifier in modifiers) {
        builder.add(modifier * item.massMultiplier);
      }
    } else {
      for (final modifier in modifiers) {
        builder.add(modifier);
      }
    }
  }

  @override
  Future<void> onUse(ItemEntry item) async {
    var builder = AttrModifierBuilder();
    buildAttrModification(item, builder);
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
    ItemGetter<Item>? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      useType,
      modifiers,
      afterUsedItem: afterUsed,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }

  Item asEatable(
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.eat,
      modifiers,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }

  Item asUsable(
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.use,
      modifiers,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }

  Item asDrinkable(
    List<AttrModifier> modifiers, {
    ItemGetter<Item>? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      UseType.drink,
      modifiers,
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

  CookableComp(
    this.cookType,
    this.fuelCost,
    this.cookedOutput,
  );

  double getActualFuelCost(ItemEntry item) {
    if (item.meta.mergeable) {
      return item.massMultiplier * fuelCost;
    } else {
      return fuelCost;
    }
  }

  @override
  void validateItemConfig(Item item) {
    if (item.hasComp(CookableComp)) {
      throw ItemCompConflictError(
        "Only allow one $CookableComp.",
        item,
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
  }) {
    final comp = CookableComp(
      cookType,
      fuelCost,
      output,
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

  FuelComp(this.heatValue);

  /// If the [item] has [WetComp], reduce the [heatValue] based on its wet.
  double getActualHeatValue(ItemEntry item) {
    final wetComp = item.meta.tryGetFirstComp<WetComp>();
    final wet = wetComp?.getWet(item) ?? 0.0;
    return heatValue * (1.0 - wet);
  }

  static const type = "Fuel";

  @override
  String get typeName => type;

  factory FuelComp.fromJson(Map<String, dynamic> json) => _$FuelCompFromJson(json);
}

extension FuelCompX on Item {
  Item asFuel({
    required double heatValue,
  }) {
    final comp = FuelComp(
      heatValue,
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
    final fromMass = from.actualMass;
    final toMass = to.actualMass;
    final fromWet = getWet(from) * fromMass;
    final toWet = getWet(to) * toMass;
    final merged = (fromWet + toWet) / (fromMass + toMass);
    setWet(to, merged);
  }

  @override
  void validateItemConfig(Item item) {
    if (item.hasComp(WetComp)) {
      throw ItemCompConflictError(
        "Only allow one $WetComp.",
        item,
      );
    }
  }

  static const type = "Wet";

  @override
  String get typeName => "Wet";
}

extension WetCompX on Item {
  Item hasWet() {
    final comp = WetComp();
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}

class FreshnessComp extends ItemComp {
  static const _freshnessK = "Freshness.freshness";

  Ratio geFreshness(ItemEntry item) => item[_freshnessK] ?? 1.0;

  void setFreshness(ItemEntry item, Ratio value) => item[_freshnessK] = value;

  @override
  void onMerge(ItemEntry from, ItemEntry to) {
    if (!from.hasIdenticalMeta(to)) return;
    final fromMass = from.actualMass;
    final toMass = to.actualMass;
    final fromFreshness = geFreshness(from) * fromMass;
    final toFreshness = geFreshness(to) * toMass;
    final merged = (toFreshness + fromFreshness) / (fromMass + toMass);
    setFreshness(to, merged);
  }

  @override
  void validateItemConfig(Item item) {
    if (item.hasComp(FreshnessComp)) {
      throw ItemCompConflictError(
        "Only allow one $FreshnessComp.",
        item,
      );
    }
  }

  static const type = "Freshness";

  @override
  String get typeName => type;
}

extension FreshnessCompX on Item {
  Item hasFreshness() {
    final comp = FreshnessComp();
    comp.validateItemConfig(this);
    addComp(comp);
    return this;
  }
}
