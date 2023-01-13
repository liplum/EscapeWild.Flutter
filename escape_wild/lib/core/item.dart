import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

typedef ItemGetter<T extends Item> = T Function();

class NamedItemGetter<T extends Item> {
  final String name;

  const NamedItemGetter(this.name);

  static ItemGetter<T> create<T extends Item>(String name) => NamedItemGetter(name).get as ItemGetter<T>;

  T get() => Contents.getItemMetaByName(name) as T;
}

extension NamedItemGetterX on String {
  ItemGetter<T> getAsItem<T extends Item>() => NamedItemGetter.create<T>(this);
}

class Item with Moddable, TagsMixin, CompMixin<ItemComp> {
  static final empty = Item("empty", mergeable: true, mass: 0, isContainer: false);
  final String name;

  /// ## When [mergeable] is false
  /// It means the item is unmergeable, and [mass] is for one ItemEntry.
  /// ### Example
  /// [mass] of `Tinned Tomatoes` is 500. So each ItemEntry takes 500g room in backpack.
  /// When player eat or cook it, if possible, [ModifyAttrComp.modifiers] and [CookableComp.fuelCost] will apply full changes.
  ///
  /// ## When [mergeable] is true
  /// It means the item is mergeable, and [mass] is the unit for each ItemEntry.
  /// ### Example
  /// [mass] of `Berry` is 10. However, ItemEntry doesn't care that, it could have an independent [ItemEntry.mass] instead.
  /// When player eat or cook it, [ModifyAttrComp.modifiers] and [CookableComp.fuelCost] will apply changes based [ItemEntry.mass].
  /// If [ItemEntry.mass] is 25, and player has eaten 15g, then [ModifyAttrComp.modifiers] will apply `(15.0 / 10.0) * modifier`.
  ///
  /// ## When [isContainer] is true
  /// It means the item is a container, and [mass] stands for the weight of container itself.
  ///
  /// Unit: [g] gram
  final int mass;
  final bool mergeable;

  /// If this item [isContainer], it must not be [mergeable].
  final bool isContainer;

  Item(
    this.name, {
    required this.mergeable,
    required this.mass,
    required this.isContainer,
  }) {
    assert(mergeable != isContainer, "`mergeable` and `isContainer` are conflict.");
  }

  Item.unmergeable(
    this.name, {
    required this.mass,
    this.isContainer = false,
  }) : mergeable = false;

  Item.container(
    this.name, {
    required this.mass,
  })  : mergeable = false,
        isContainer = true;

  Item.mergeable(this.name, {required this.mass})
      : mergeable = true,
        isContainer = false;

  Item self() => this;

  String l10nName() => i18n("item.$name.name");

  String l10nDescription() => i18n("item.$name.desc");
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
      // If the `ItemEntry.mass` is not specified, use `Item.mass`.
      return ItemEntry(this, mass: this.mass);
    } else {
      assert(mass == null && massF == null, "`mass` and `massFactor` should be both null for unmergeable");
      return ItemEntry(this);
    }
  }

  List<ItemEntry> repeat(int number) {
    assert(number > 0, "`number` should be over than 0.");
    assert(!mergeable, "only unmergeable can be generated repeatedly, but $name is given.");
    if (mergeable) {
      // For mergeable, it will multiply the mass.
      return [ItemEntry(this, mass: mass * number)];
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

  /// ## preconditions:
  /// - The [ItemEntry.mass] of [from] and [to] are not changed.
  /// ## contrarians:
  /// - Implementation mustn't change [ItemEntry.mass].
  void onMerge(ItemEntry from, ItemEntry to) {}

  /// ## preconditions:
  /// - The [ItemEntry.mass] of [from] and [to] are not changed.
  /// - [to] has an [Item.extra] clone from [from].
  /// ## contrarians:
  /// - Implementation mustn't change [ItemEntry.mass].
  void onSplit(ItemEntry from, ItemEntry to) {}
}

class ItemCompPair<T extends Comp> {
  final ItemEntry item;
  final T comp;

  const ItemCompPair(this.item, this.comp);
}

@JsonSerializable()
class ItemEntry with ExtraMixin implements JConvertibleProtocol {
  static final empty = ItemEntry(Item.empty);
  @JsonKey(fromJson: Contents.getItemMetaByName, toJson: _getItemMetaName)
  final Item meta;

  @JsonKey(includeIfNull: false)
  int? mass;

  int get entryMass => mass ?? meta.mass;

  ItemEntry(
    this.meta, {
    this.mass,
  });

  String displayName() => meta.l10nName();

  bool hasIdenticalMeta(ItemEntry other) => meta == other.meta;

  bool conformTo(Item meta) => this.meta == meta;

  bool get canSplit => meta.mergeable;

  bool get canMerge => meta.mergeable;

  bool get isEmpty => identical(this, empty) || meta == Item.empty || entryMass <= 0;

  @override
  String toString() {
    final m = mass;
    final name = meta.l10nName();
    if (m == null) {
      return name;
    } else {
      return "$name ${m.toStringAsFixed(1)}g";
    }
  }

  /// Please call [Backpack.addItemOrMerge] to track changes, such as [Backpack.mass].
  void mergeTo(ItemEntry to) {
    assert(meta.mergeable, "${meta.name} is not mergeable.");
    if (!meta.mergeable) return;
    assert(hasIdenticalMeta(to), "Can't merge ${meta.name} with ${to.meta.name}.");
    if (!hasIdenticalMeta(to)) return;
    final selfMass = entryMass;
    final toMass = to.entryMass;
    // handle components
    for (final comp in meta.iterateComps()) {
      comp.onMerge(this, to);
    }
    to.mass = selfMass + toMass;
  }

  /// Please call [Backpack.splitItemInBackpack] to track changes, such as [Backpack.mass].
  /// ```dart
  /// if(canSplit)
  ///   mass = actualMass - massOfPart;
  /// ```
  ItemEntry split(int massOfPart) {
    assert(massOfPart > 0, "`mass` to split must be more than 0");
    if (massOfPart <= 0) return empty;
    assert(entryMass >= massOfPart, "Self `mass` must be more than `mass` to split.");
    if (entryMass < massOfPart) return empty;
    assert(canSplit, "${meta.name} can't be split.");
    if (!canSplit) return empty;
    final selfMass = entryMass;
    // if self mass is less than or equal to mass to split, return a clone.
    if (selfMass <= massOfPart) return clone();
    final part = ItemEntry(meta, mass: massOfPart);
    // clone extra
    part.extra = cloneExtra();
    // handle components
    for (final comp in meta.iterateComps()) {
      comp.onSplit(this, part);
    }
    mass = selfMass - massOfPart;
    return part;
  }

  factory ItemEntry.fromJson(Map<String, dynamic> json) => _$ItemEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ItemEntryToJson(this);

  ItemEntry clone() {
    final cloned = ItemEntry(meta, mass: mass);
    cloned.extra = cloneExtra();
    return cloned;
  }

  static const type = "ItemEntry";

  @override
  String get typeName => type;
}

@JsonSerializable()
class ContainerItemEntry extends ItemEntry {
  @JsonKey(includeIfNull: false)
  ItemEntry? inner;

  @override
  set mass(int? newMass) {
    assert(false, "ContainerItemEntry's mass can't be changed.");
  }

  /// [entryMass] is the sum of container and [inner].
  @override
  int get entryMass => insideMass + meta.mass;

  int get insideMass => inner?.entryMass ?? 0;

  ContainerItemEntry(super.meta) {
    assert(meta.isContainer, "ContainerItemEntry requires item is a Container.");
  }

  bool get containsItem => inner?.isNotEmpty != true;

  @override
  String displayName() {
    final inner = this.inner;
    if (inner == null) {
      return meta.l10nName();
    } else {
      return "${meta.l10nName()}[${inner.displayName()}]";
    }
  }

  factory ContainerItemEntry.fromJson(Map<String, dynamic> json) => _$ContainerItemEntryFromJson(json);

  /// The container itself can't be merged.
  @override
  bool get canMerge => false;

  /// The container itself can't be split.
  @override
  bool get canSplit => false;

  /// The container itself can't be merge.
  @override
  void mergeTo(ItemEntry to) {}

  /// The container itself can't be split.
  @override
  ItemEntry split(int massOfPart) {
    return this;
  }

  @override
  Map<String, dynamic> toJson() => _$ContainerItemEntryToJson(this);

  static const type = "ContainerItemEntry";

  @override
  String get typeName => type;
}

extension ItemEntryX on ItemEntry {
  double get massMultiplier => entryMass / meta.mass;

  bool canMergeTo(ItemEntry to) {
    return hasIdenticalMeta(to) && meta.mergeable;
  }

  bool get isNotEmpty => !isEmpty;
}

extension ItemEntryListX on List<ItemEntry> {
  ItemEntry? findFirstByName(String name) {
    for (final item in this) {
      if (item.meta.name == name) {
        return item;
      }
    }
    return null;
  }

  ItemEntry? findFirstByTag(String tag) {
    for (final item in this) {
      if (item.meta.hasTag(tag)) {
        return item;
      }
    }
    return null;
  }

  ItemEntry? findFirstByTags(Iterable<String> tags) {
    for (final item in this) {
      if (item.meta.hasTags(tags)) {
        return item;
      }
    }
    return null;
  }

  Iterable<ItemEntry> findAllByTag(String tag) sync* {
    for (final item in this) {
      if (item.meta.hasTag(tag)) {
        yield item;
      }
    }
  }

  Iterable<ItemEntry> findAllByTags(Iterable<String> tags) sync* {
    for (final item in this) {
      if (item.meta.hasTags(tags)) {
        yield item;
      }
    }
  }

  void addItemOrMergeAll(List<ItemEntry> additions) {
    for (final addition in additions) {
      addItemOrMerge(addition);
    }
  }

  void addItemOrMerge(ItemEntry addition) {
    var merged = false;
    for (final result in this) {
      if (addition.canMergeTo(result)) {
        addition.mergeTo(result);
        merged = true;
        break;
      }
    }
    if (!merged) {
      add(addition);
    }
  }
}

class ItemMatcher {
  final bool Function(Item item) typeOnly;
  final bool Function(ItemEntry item) exact;

  const ItemMatcher({
    required this.typeOnly,
    required this.exact,
  });
}

extension ItemMatcherX on ItemMatcher {
  Iterable<Item> filterTypeMatchedItems(Iterable<Item> items, {bool requireMatched = true}) sync* {
    for (final item in items) {
      if (requireMatched) {
        if (typeOnly(item)) {
          yield item;
        }
      } else {
        if (!typeOnly(item)) {
          yield item;
        }
      }
    }
  }

  Iterable<ItemEntry> filterExactMatchedEntries(Iterable<ItemEntry> items, {bool requireMatched = true}) sync* {
    for (final item in items) {
      if (requireMatched) {
        if (exact(item)) {
          yield item;
        }
      } else {
        if (!exact(item)) {
          yield item;
        }
      }
    }
  }

  Iterable<ItemEntry> filterTypedMatchedEntries(Iterable<ItemEntry> items, {bool requireMatched = true}) sync* {
    for (final item in items) {
      if (requireMatched) {
        if (typeOnly(item.meta)) {
          yield item;
        }
      } else {
        if (!typeOnly(item.meta)) {
          yield item;
        }
      }
    }
  }
}

class EmptyComp extends Comp {
  static const type = "Empty";

  @override
  String get typeName => type;
}

String _getItemMetaName(Item meta) => meta.name;

@JsonSerializable(createToJson: false)
class ToolAttr implements Comparable<ToolAttr> {
  @JsonKey()
  final double efficiency;
  @JsonKey()
  final double durability;

  const ToolAttr({required this.efficiency, required this.durability});

  static const ToolAttr low = ToolAttr(
        efficiency: 0.6,
        durability: 0.6,
      ),
      normal = ToolAttr(
        efficiency: 1.0,
        durability: 1.0,
      ),
      high = ToolAttr(
        efficiency: 1.8,
        durability: 1.5,
      ),
      max = ToolAttr(
        efficiency: 2.0,
        durability: 2.0,
      );

  /// When [durability] is under zero, tool will suffer more damage.
  double fixDamage(double damage) {
    // TODO: Better formula
    return damage / durability;
  }

  factory ToolAttr.fromJson(Map<String, dynamic> json) => _$ToolAttrFromJson(json);

  @override
  int compareTo(ToolAttr other) => efficiency.compareTo(other.efficiency);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ToolAttr || runtimeType != other.runtimeType) return false;
    return efficiency == other.efficiency;
  }

  @override
  int get hashCode => efficiency.hashCode;
}

class ToolType {
  final String name;

  const ToolType(this.name);

  factory ToolType.named(String name) => ToolType(name);

  static const ToolType cutting = ToolType("cutting");

  /// Use to cut down tree
  static const ToolType axe = ToolType("axe");

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
  @JsonKey(fromJson: ToolAttr.fromJson)
  final ToolAttr attr;
  @JsonKey()
  final double maxHealth;
  @JsonKey(fromJson: ToolType.named)
  final ToolType toolType;

  ToolComp({
    this.attr = ToolAttr.normal,
    required this.toolType,
    required this.maxHealth,
  });

  void damageTool(ItemEntry item, double damage) {
    damage = attr.fixDamage(damage);
    final former = getHealth(item);
    setHealth(item, former - damage);
  }

  double getHealth(ItemEntry item) => item["Tool.health"] ?? 0.0;

  bool isBroken(ItemEntry item) => getHealth(item) <= 0;

  void setHealth(ItemEntry item, double value) => item["Tool.health"] = value;

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
    ToolAttr attr = ToolAttr.normal,
    required double health,
  }) {
    final comp = ToolComp(
      attr: attr,
      toolType: type,
      maxHealth: health,
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
  eat,
  equip;

  String l10nName() => I18n["use-type.$name"];
}

abstract class UsableComp extends ItemComp {
  @JsonKey()
  final UseType useType;

  UsableComp(this.useType);

  bool canUse() => true;

  Future<void> onUse(ItemEntry item) async {}

  bool get displayPreview => true;
  static const type = "Usable";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class ModifyAttrComp extends UsableComp {
  @override
  Type get compType => UsableComp;
  @JsonKey()
  final List<AttrModifier> modifiers;
  @JsonKey(fromJson: NamedItemGetter.create)
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
    final afterUsedItem = this.afterUsedItem;
    if (afterUsedItem != null) {
      final item = afterUsedItem();
      final entry = item.create();
      player.backpack.addItemOrMerge(entry);
    }
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
  @JsonKey(fromJson: NamedItemGetter.create)
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
    final wetComp = item.meta.getFirstComp<WetComp>();
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
  static const defaultWet = 0.0;

  Ratio getWet(ItemEntry item) => item[_wetK] ?? defaultWet;

  void setWet(ItemEntry item, Ratio value) => item[_wetK] = value;

  @override
  void onMerge(ItemEntry from, ItemEntry to) {
    if (!from.hasIdenticalMeta(to)) return;
    final fromMass = from.entryMass;
    final toMass = to.entryMass;
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

  static WetComp? of(ItemEntry item) => item.meta.getFirstComp<WetComp>();

  static double tryGetWet(ItemEntry item) => item.meta.getFirstComp<WetComp>()?.getWet(item) ?? defaultWet;

  static void trySetWet(ItemEntry item, double wet) => item.meta.getFirstComp<WetComp>()?.setWet(item, wet);
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
    final fromMass = from.entryMass;
    final toMass = to.entryMass;
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
