import 'dart:math';
import 'dart:ui';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/utils/random.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item_comp.g.dart';

/// An [Item] can have at most one [DurabilityComp].
@JsonSerializable(createToJson: false)
class DurabilityComp extends ItemComp {
  static const _durabilityK = "Durability.durability";

  /// the maximum durability
  /// If no durability is initialized, [max] will be considered as default.
  @JsonKey()
  final double max;

  /// Whether the durability of [ItemStack] can exceed maximum.
  @JsonKey()
  final bool allowExceed;

  const DurabilityComp({
    required this.max,
    this.allowExceed = false,
  });

  double getDurability(ItemStack stack) => stack[_durabilityK] ?? max;

  bool isBroken(ItemStack stack) {
    if (max <= 0.0) return false;
    return getDurability(stack) <= 0.0;
  }

  void setDurability(ItemStack stack, double value) => stack[_durabilityK] = allowExceed ? value : value.clamp(0, max);

  Ratio getDurabilityRatio(ItemStack stack) {
    if (max <= 0.0) return 1;
    return getDurability(stack) / max;
  }

  @override
  void onMerge(ItemStack from, ItemStack to) {
    if (!from.hasIdenticalMeta(to)) return;
    setDurability(to, getDurability(from) + getDurability(to));
  }

  @override
  void validateItemConfig(Item item) {
    if (item.hasComp(DurabilityComp)) {
      throw ItemCompConflictError(
        "Only allow one $DurabilityComp.",
        item,
      );
    }
  }

  @override
  void buildStatus(ItemStack stack, ItemStackStatusBuilder builder) {
    final ratio = getDurabilityRatio(stack);
    final percent = (ratio * 100).toInt();
    final label = " $percent% Durability";
    final color = _progressColor(ratio, darkMode: builder.darkMode);
    builder << ItemStackStatus(name: label, color: color);
  }

  Color _progressColor(Ratio ratio, {required bool darkMode}) {
    if (ratio >= 0.8) {
      return darkMode ? StatusColorPreset.goodDark : StatusColorPreset.good;
    } else if (ratio >= 0.5) {
      return darkMode ? StatusColorPreset.normalDark : StatusColorPreset.normal;
    } else if (ratio >= 0.2) {
      return darkMode ? StatusColorPreset.warningDark : StatusColorPreset.warning;
    } else {
      return darkMode ? StatusColorPreset.worstDark : StatusColorPreset.worst;
    }
  }

  Color progressColor(ItemStack stack, {required bool darkMode}) {
    final ratio = getDurabilityRatio(stack);
    return _progressColor(ratio, darkMode: darkMode);
  }

  static DurabilityComp? of(ItemStack stack) => stack.meta.getFirstComp<DurabilityComp>();

  static double tryGetDurability(ItemStack stack) => of(stack)?.getDurability(stack) ?? 0.0;

  /// Default is false
  static bool tryGetIsBroken(ItemStack stack) => of(stack)?.isBroken(stack) ?? false;

  /// Default is 1.0
  static double tryGetDurabilityRatio(ItemStack stack) => of(stack)?.getDurabilityRatio(stack) ?? 1.0;

  static void trySetDurability(ItemStack stack, double durability) => of(stack)?.setDurability(stack, durability);

  factory DurabilityComp.fromJson(Map<String, dynamic> json) => _$DurabilityCompFromJson(json);
  static const type = "Durability";

  @override
  String get typeName => type;
}

extension DurabilityCompX on Item {
  Item hasDurability({
    required double max,
    bool allowExceed = false,
  }) {
    final comp = DurabilityComp(
      max: max,
      allowExceed: allowExceed,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}

@JsonSerializable(createToJson: false)
class ToolAttr implements Comparable<ToolAttr> {
  @JsonKey()
  final double efficiency;

  const ToolAttr({required this.efficiency});

  static const ToolAttr low = ToolAttr(
        efficiency: 0.6,
      ),
      normal = ToolAttr(
        efficiency: 1.0,
      ),
      high = ToolAttr(
        efficiency: 1.8,
      ),
      max = ToolAttr(
        efficiency: 2.0,
      );

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

class ToolType with Moddable {
  @override
  final String name;

  ToolType(this.name);

  factory ToolType.fromJson(String name) => ToolType(name);

  String toJson() => name;
  static final ToolType cutting = ToolType("cutting");

  /// Use to cut down tree
  static final ToolType axe = ToolType("axe");

  /// Use to hunt
  static final ToolType trap = ToolType("trap");

  /// Use to hunt
  static final ToolType gun = ToolType("gun");

  /// Use to fish
  static final ToolType fishing = ToolType("fishing");

  /// Use to light
  static final ToolType lighting = ToolType("lighting");

  String l10nName() => i18n("tool-type.$name");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ToolType || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// An [Item] can have at most one [ToolComp] for each different [ToolType].
@JsonSerializable(createToJson: false)
class ToolComp extends ItemComp {
  @JsonKey(fromJson: ToolAttr.fromJson)
  final ToolAttr attr;
  @JsonKey(fromJson: ToolType.fromJson)
  final ToolType toolType;

  const ToolComp({
    this.attr = ToolAttr.normal,
    required this.toolType,
  });

  void damageTool(ItemStack item, double damage) {
    final durabilityComp = DurabilityComp.of(item);
    // the tool is unbreakable
    if (durabilityComp == null) return;
    final former = durabilityComp.getDurability(item);
    durabilityComp.setDurability(item, former - damage);
  }

  bool isBroken(ItemStack item) {
    return DurabilityComp.tryGetIsBroken(item);
  }

  @override
  void validateItemConfig(Item item) {
    if (item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$ToolComp doesn't conform to mergeable item.",
        item,
        mergeableShouldBe: false,
      );
    }
    for (final comp in item.getCompsOf<ToolComp>()) {
      if (comp.toolType == toolType) {
        throw ItemCompConflictError("$ToolComp already exists for $toolType.", item);
      }
    }
  }

  static Iterable<ToolComp> of(ItemStack stack) => stack.meta.getCompsOf<ToolComp>();

  static ToolComp? ofType(ItemStack stack, ToolType toolType) {
    for (final comp in stack.meta.getCompsOf<ToolComp>()) {
      if (comp.toolType == toolType) {
        return comp;
      }
    }
    return null;
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
  }) {
    final comp = ToolComp(
      attr: attr,
      toolType: type,
    );
    comp.validateItemConfigIfDebug(this);
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

/// An [Item] can have multiple [UsableComp].
abstract class UsableComp extends ItemComp {
  /// The [compType] of subclass should be the same as [UsableComp].
  @override
  Type get compType => UsableComp;
  @JsonKey()
  final UseType useType;

  const UsableComp(this.useType);

  /// Whether player can use [stack].
  bool canUse(ItemStack stack) => true;

  /// When [stack] is used.
  Future<void> onUse(ItemStack stack) async {}

  static Iterable<UsableComp> of(ItemStack stack) => stack.meta.getCompsOf<UsableComp>();
}

@JsonSerializable(createToJson: false)
class ModifyAttrComp extends UsableComp {
  @JsonKey()
  final Iterable<AttrModifier> modifiers;
  @itemGetterJsonKey
  final ItemGetter? afterUsedItem;

  const ModifyAttrComp(
    super.useType,
    this.modifiers, {
    this.afterUsedItem,
  });

  bool get displayPreview => true;

  void buildAttrModification(ItemStack item, AttrModifierBuilder builder) {
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
  Future<void> onUse(ItemStack stack) async {
    var builder = AttrModifierBuilder();
    buildAttrModification(stack, builder);
    builder.performModification(player);
    final afterUsedItem = this.afterUsedItem;
    if (afterUsedItem != null) {
      final item = afterUsedItem();
      final entry = item.create();
      player.backpack.addItemOrMerge(entry);
    }
  }

  factory ModifyAttrComp.fromJson(Map<String, dynamic> json) => _$ModifyAttrCompFromJson(json);

  static const type = "AttrModify";

  @override
  String get typeName => type;
}

extension ModifyAttrCompX on Item {
  Item modifyAttr(
    UseType useType,
    List<AttrModifier> modifiers, {
    ItemGetter? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      useType,
      modifiers,
      afterUsedItem: afterUsed,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item asEatable(
    List<AttrModifier> modifiers, {
    ItemGetter? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.eat,
      modifiers,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item asUsable(
    List<AttrModifier> modifiers, {
    ItemGetter? afterUsedItem,
  }) {
    final comp = ModifyAttrComp(
      UseType.use,
      modifiers,
      afterUsedItem: afterUsedItem,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item asDrinkable(
    List<AttrModifier> modifiers, {
    ItemGetter? afterUsed,
  }) {
    final comp = ModifyAttrComp(
      UseType.drink,
      modifiers,
      afterUsedItem: afterUsed,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}

/// An [Item] can have at most one [FuelComp].
@JsonSerializable(createToJson: false)
class FuelComp extends ItemComp {
  @JsonKey()
  final double heatValue;

  const FuelComp(this.heatValue);

  /// If the [stack] has [WetnessComp], reduce the [heatValue] based on its wet.
  double getActualHeatValue(ItemStack stack) {
    var res = heatValue * stack.massMultiplier;
    // check wet
    final wet = WetnessComp.tryGetWetness(stack);
    res *= 1.0 - wet;
    // check durability
    final ratio = DurabilityComp.tryGetDurabilityRatio(stack);
    res *= ratio;
    return res;
  }

  static FuelComp? of(ItemStack stack) => stack.meta.getFirstComp<FuelComp>();

  static double tryGetActualHeatValue(ItemStack stack) => of(stack)?.getActualHeatValue(stack) ?? 0.0;
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
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}

/// An [Item] can have at most one [WetnessComp].
@JsonSerializable(createToJson: false)
class WetnessComp extends ItemComp {
  static const _wetK = "Wet.wetness";
  static const defaultWetness = 0.0;
  static const defaultDryTime = Ts.from(hour: 12);
  final Ts dryTime;

  const WetnessComp({
    this.dryTime = WetnessComp.defaultDryTime,
  });

  Ratio getWetness(ItemStack stack) => stack[_wetK] ?? defaultWetness;

  void setWetness(ItemStack stack, Ratio value) => stack[_wetK] = value.clamp(0.0, 1.0);

  @override
  void onMerge(ItemStack from, ItemStack to) {
    if (!from.hasIdenticalMeta(to)) return;
    final fromMass = from.stackMass;
    final toMass = to.stackMass;
    final fromWet = getWetness(from) * fromMass;
    final toWet = getWetness(to) * toMass;
    final merged = (fromWet + toWet) / (fromMass + toMass);
    setWetness(to, merged);
  }

  @override
  Future<void> onPassTime(ItemStack stack, Ts delta) async {
    final lost = delta / dryTime;
    final wet = getWetness(stack);
    setWetness(stack, wet - lost);
  }

  @override
  void validateItemConfig(Item item) {
    if (item.hasComp(WetnessComp)) {
      throw ItemCompConflictError(
        "Only allow one $WetnessComp.",
        item,
      );
    }
  }

  @override
  void buildStatus(ItemStack stack, ItemStackStatusBuilder builder) {
    final ratio = getWetness(stack);
    if (ratio >= 0.8) {
      builder <<
          ItemStackStatus(
            name: "Soaked",
            color: builder.darkMode ? StatusColorPreset.wetDark : StatusColorPreset.wet,
          );
    } else if (ratio >= 0.5) {
      builder <<
          ItemStackStatus(
            name: "Wet",
            color: builder.darkMode ? StatusColorPreset.wetDark : StatusColorPreset.wet,
          );
    } else if (ratio >= 0.3) {
      builder <<
          ItemStackStatus(
            name: "Soggy",
            color: builder.darkMode ? StatusColorPreset.wetDark : StatusColorPreset.wet,
          );
    }
  }

  static WetnessComp? of(ItemStack stack) => stack.meta.getFirstComp<WetnessComp>();

  /// default: [defaultWetness]
  static double tryGetWetness(ItemStack stack) => of(stack)?.getWetness(stack) ?? defaultWetness;

  static void trySetWetness(ItemStack stack, double wet) => of(stack)?.setWetness(stack, wet);
  static const type = "Wetness";

  @override
  String get typeName => type;

  factory WetnessComp.fromJson(Map<String, dynamic> json) => _$WetnessCompFromJson(json);
}

extension WetnessCompX on Item {
  Item hasWetness({
    Ts dryTime = WetnessComp.defaultDryTime,
  }) {
    final comp = WetnessComp(
      dryTime: dryTime,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}

/// An [Item] can have at most one [FreshnessComp].
@JsonSerializable(createToJson: false)
class FreshnessComp extends ItemComp {
  static const _freshnessK = "Freshness.freshness";

  /// how much time the item will be completely rotten.
  @JsonKey()
  final Ts expire;

  /// how fast the food going spoiled when it's wet.
  /// ```dart
  /// final actualWetRatio = wetness * wetFactor;
  /// ```
  @JsonKey()
  final double wetFactor;
  static const defaultWetFactor = 0.6;

  const FreshnessComp({
    required this.expire,
    this.wetFactor = FreshnessComp.defaultWetFactor,
  });

  Ratio getFreshness(ItemStack stack) => stack[_freshnessK] ?? 1.0;

  void setFreshness(ItemStack stack, Ratio value) => stack[_freshnessK] = value.clamp(0.0, 1.0);

  @override
  void onMerge(ItemStack from, ItemStack to) {
    if (!from.hasIdenticalMeta(to)) return;
    final fromMass = from.stackMass;
    final toMass = to.stackMass;
    final fromFreshness = getFreshness(from) * fromMass;
    final toFreshness = getFreshness(to) * toMass;
    final merged = (fromFreshness + toFreshness) / (fromMass + toMass);
    setFreshness(to, merged);
  }

  @override
  Future<void> onPassTime(ItemStack stack, Ts delta) async {
    final wetness = WetnessComp.tryGetWetness(stack);
    final lost = delta / expire * (1 + wetness * wetFactor);
    final freshness = getFreshness(stack);
    setFreshness(stack, freshness - lost);
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

  @override
  void buildStatus(ItemStack stack, ItemStackStatusBuilder builder) {
    final ratio = getFreshness(stack);
    if (ratio >= 0.7) {
      builder <<
          ItemStackStatus(
            name: "Fresh",
            color: builder.darkMode ? StatusColorPreset.goodDark : StatusColorPreset.good,
          );
    } else if (ratio >= 0.4) {
      builder <<
          ItemStackStatus(
            name: "Stale",
            color: builder.darkMode ? StatusColorPreset.normalDark : StatusColorPreset.normal,
          );
    } else if (ratio >= 0.2) {
      builder <<
          ItemStackStatus(
            name: "Spoiled",
            color: builder.darkMode ? StatusColorPreset.warningDark : StatusColorPreset.warning,
          );
    } else {
      builder <<
          ItemStackStatus(
            name: "Rotten",
            color: builder.darkMode ? StatusColorPreset.worstDark : StatusColorPreset.worst,
          );
    }
  }

  Color progressColor(ItemStack stack, {required bool darkMode}) {
    final ratio = getFreshness(stack);
    if (ratio >= 0.7) {
      return darkMode ? StatusColorPreset.goodDark : StatusColorPreset.good;
    } else if (ratio >= 0.4) {
      return darkMode ? StatusColorPreset.normalDark : StatusColorPreset.normal;
    } else if (ratio >= 0.2) {
      return darkMode ? StatusColorPreset.warningDark : StatusColorPreset.warning;
    } else {
      return darkMode ? StatusColorPreset.worstDark : StatusColorPreset.worst;
    }
  }

  static FreshnessComp? of(ItemStack stack) => stack.meta.getFirstComp<FreshnessComp>();

  static const type = "Freshness";

  @override
  String get typeName => type;

  factory FreshnessComp.fromJson(Map<String, dynamic> json) => _$FreshnessCompFromJson(json);
}

extension FreshnessCompX on Item {
  Item hasFreshness({
    required Ts expire,
  }) {
    final comp = FreshnessComp(expire: expire);
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}

/// An [Item] can have at most one [FireStarterComp].
@JsonSerializable(createToJson: false)
class FireStarterComp extends ItemComp {
  final Ratio chance;
  final double cost;

  /// Whether to consume this fire starter after fire is burning.
  /// If so, campfire will gain [FuelComp.getActualHeatValue] amount of fuel.
  final bool consumeSelfAfterBurning;

  const FireStarterComp({
    required this.chance,
    required this.cost,
    this.consumeSelfAfterBurning = true,
  });

  bool tryStartFire(ItemStack stack, [Random? rand]) {
    rand ??= Rand.backend;
    var chance = this.chance;
    // check wet
    final wet = WetnessComp.tryGetWetness(stack);
    chance *= 1.0 - wet;
    final success = rand.one() <= chance;
    final durabilityComp = DurabilityComp.of(stack);
    if (durabilityComp != null) {
      final durability = durabilityComp.getDurability(stack);
      durabilityComp.setDurability(stack, durability - cost);
    }
    return success;
  }

  @override
  void validateItemConfig(Item item) {
    if (item.mergeable) {
      throw ItemMergeableCompConflictError(
        "$FireStarterComp doesn't conform to mergeable item.",
        item,
        mergeableShouldBe: false,
      );
    }
    if (item.hasComp(FireStarterComp)) {
      throw ItemCompConflictError(
        "Only allow one $FireStarterComp.",
        item,
      );
    }
  }

  static FireStarterComp? of(ItemStack stack) => stack.meta.getFirstComp<FireStarterComp>();

  static const type = "FireStarter";

  @override
  String get typeName => type;

  factory FireStarterComp.fromJson(Map<String, dynamic> json) => _$FireStarterCompFromJson(json);
}

extension FireStarterCompX on Item {
  Item asFireStarter({
    required Ratio chance,
    required double cost,
    bool consumeSelfAfterBurning = true,
  }) {
    final comp = FireStarterComp(
      chance: chance,
      cost: cost,
      consumeSelfAfterBurning: consumeSelfAfterBurning,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}

@JsonEnum()
enum ItemProp {
  mass,
  wetness,
  durability,
  freshness;
}

extension ItemPropX on ItemProp {
  ItemPropModifier operator +(double deltaPerMinute) => ItemPropModifier(this, deltaPerMinute);

  ItemPropModifier operator -(double deltaPerMinute) => ItemPropModifier(this, -deltaPerMinute);
}

@JsonSerializable(createToJson: false)
class ItemPropModifier {
  @JsonKey()
  final ItemProp prop;
  @JsonKey()
  final double deltaPerMinute;

  const ItemPropModifier(this.prop, this.deltaPerMinute);

  /// ## Supported format:
  /// - original json object:
  /// ```json
  /// {
  ///   "attr":"durability",
  ///   "deltaPerMinute": -1.5
  /// }
  /// ```
  /// - String literal:
  /// ```json
  /// "durability/-1.5"
  /// ```
  factory ItemPropModifier.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return _$ItemPropModifierFromJson(json);
    } else {
      final literal = json.toString();
      final ItemProp prop;
      final double deltaPerMinute;
      final attrNDelta = literal.split("/");
      prop = $enumDecode(_$ItemPropEnumMap, attrNDelta[0]);
      deltaPerMinute = num.parse(attrNDelta[1]).toDouble();
      return ItemPropModifier(prop, deltaPerMinute);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ItemPropModifier || other.runtimeType != runtimeType) return false;
    return prop == other.prop && deltaPerMinute == other.deltaPerMinute;
  }

  @override
  int get hashCode => Object.hash(prop, deltaPerMinute);
}

extension ItemPropModifierX on ItemPropModifier {
  ItemPropModifier operator +(double deltaPerMinute) => ItemPropModifier(prop, this.deltaPerMinute + deltaPerMinute);

  ItemPropModifier operator -(double deltaPerMinute) => ItemPropModifier(prop, this.deltaPerMinute + deltaPerMinute);

  ItemPropModifier operator *(double factor) => ItemPropModifier(prop, deltaPerMinute * factor);

  ItemPropModifier operator /(double factor) => ItemPropModifier(prop, deltaPerMinute / factor);
}

@JsonSerializable(createToJson: false)
class ContinuousModifyItemPropComp extends ItemComp {
  @JsonKey()
  final Iterable<ItemPropModifier> modifiers;

  const ContinuousModifyItemPropComp(this.modifiers);

  @override
  Future<void> onPassTime(ItemStack stack, Ts delta) async {
    for (final modifier in modifiers) {
      performModifier(stack, delta, modifier.prop, modifier.deltaPerMinute);
    }
  }

  void performModifier(ItemStack stack, Ts timePassed, ItemProp prop, double deltaPerMinute) {
    switch (prop) {
      case ItemProp.mass:
        ContinuousModifyMassComp.modify(stack, timePassed, deltaPerMinute);
        break;
      case ItemProp.wetness:
        ContinuousModifyWetnessComp.modify(stack, timePassed, deltaPerMinute);
        break;
      case ItemProp.durability:
        ContinuousModifyDurabilityComp.modify(stack, timePassed, deltaPerMinute);
        break;
      case ItemProp.freshness:
        ContinuousModifyFreshnessComp.modify(stack, timePassed, deltaPerMinute);
        break;
    }
  }

  @override
  void validateItemConfig(Item item) {
    if (item.mergeable && modifiers.any((m) => m.prop == ItemProp.mass)) {
      throw ItemCompConflictError("Can't change the mass of unmergeable item ${item.registerName}.", item);
    }
  }

  static Iterable<ContinuousModifyItemPropComp> of(ItemStack stack) =>
      stack.meta.getCompsOf<ContinuousModifyItemPropComp>();

  factory ContinuousModifyItemPropComp.fromJson(Map<String, dynamic> json) =>
      _$ContinuousModifyItemPropCompFromJson(json);
  static const type = "ContinuousModifyItemProp";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class ContinuousModifyMassComp extends ItemComp {
  @JsonKey()
  final double deltaPerMinute;

  const ContinuousModifyMassComp({
    required this.deltaPerMinute,
  });

  @override
  Future<void> onPassTime(ItemStack stack, Ts delta) async {
    modify(stack, delta, deltaPerMinute);
  }

  static modify(ItemStack stack, Ts timePassed, double deltaPerMinute) {
    final totalDelta = deltaPerMinute * timePassed.minutes;
    if (stack.meta.mergeable) {
      stack.mass = stack.stackMass + totalDelta.toInt();
      if (stack.isEmpty) {
        player.backpack.removeStackInBackpack(stack);
      }
    }
  }

  @override
  void validateItemConfig(Item item) {
    if (item.mergeable) {
      throw ItemCompConflictError("Can't change the mass of unmergeable item ${item.registerName}.", item);
    }
  }

  static Iterable<ContinuousModifyMassComp> of(ItemStack stack) => stack.meta.getCompsOf<ContinuousModifyMassComp>();

  factory ContinuousModifyMassComp.fromJson(Map<String, dynamic> json) => _$ContinuousModifyMassCompFromJson(json);
  static const type = "ContinuousModifyMass";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class ContinuousModifyWetnessComp extends ItemComp {
  @JsonKey()
  final double deltaPerMinute;

  const ContinuousModifyWetnessComp({
    required this.deltaPerMinute,
  });

  @override
  Future<void> onPassTime(ItemStack stack, Ts delta) async {
    modify(stack, delta, deltaPerMinute);
  }

  static modify(ItemStack stack, Ts timePassed, double deltaPerMinute) {
    final totalDelta = deltaPerMinute * timePassed.minutes;
    final comp = WetnessComp.of(stack);
    if (comp != null) {
      final wet = comp.getWetness(stack);
      comp.setWetness(stack, wet + totalDelta);
    }
  }

  @override
  void validateItemConfig(Item item) {
    if (item.mergeable) {
      throw ItemCompConflictError("Can't change the mass of unmergeable item ${item.registerName}.", item);
    }
  }

  factory ContinuousModifyWetnessComp.fromJson(Map<String, dynamic> json) =>
      _$ContinuousModifyWetnessCompFromJson(json);

  static Iterable<ContinuousModifyWetnessComp> of(ItemStack stack) =>
      stack.meta.getCompsOf<ContinuousModifyWetnessComp>();
  static const type = "ContinuousModifyWetness";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class ContinuousModifyDurabilityComp extends ItemComp {
  @JsonKey()
  final double deltaPerMinute;

  /// How fast the item loses durability when it's wet.
  /// ```dart
  /// final actualWetRatio = wetness * wetFactor;
  /// ```
  /// ## Use cases
  /// To reduce the durability of a torch based on its wetness.
  ///
  /// see [FreshnessComp.wetFactor]
  @JsonKey()
  final double wetFactor;
  static const defaultWetFactor = 0.0;

  const ContinuousModifyDurabilityComp({
    required this.deltaPerMinute,
    this.wetFactor = ContinuousModifyDurabilityComp.defaultWetFactor,
  });

  @override
  Future<void> onPassTime(ItemStack stack, Ts delta) async {
    modify(stack, delta, deltaPerMinute, wetFactor: wetFactor);
  }

  static modify(ItemStack stack, Ts timePassed, double deltaPerMinute, {double wetFactor = 0.0}) {
    var totalDelta = deltaPerMinute * timePassed.minutes;
    final comp = DurabilityComp.of(stack);
    if (comp != null) {
      final durability = comp.getDurability(stack);
      final wetness = WetnessComp.tryGetWetness(stack);
      totalDelta *= 1 + wetness * wetFactor;
      comp.setDurability(stack, durability + totalDelta);
      if (comp.isBroken(stack)) {
        player.backpack.removeStackInBackpack(stack);
      }
    }
  }

  factory ContinuousModifyDurabilityComp.fromJson(Map<String, dynamic> json) =>
      _$ContinuousModifyDurabilityCompFromJson(json);

  static Iterable<ContinuousModifyDurabilityComp> of(ItemStack stack) =>
      stack.meta.getCompsOf<ContinuousModifyDurabilityComp>();
  static const type = "ContinuousModifyDurability";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class ContinuousModifyFreshnessComp extends ItemComp {
  @JsonKey()
  final double deltaPerMinute;

  /// see [FreshnessComp.wetFactor]
  @JsonKey()
  final double wetFactor;

  const ContinuousModifyFreshnessComp({
    required this.deltaPerMinute,
    this.wetFactor = FreshnessComp.defaultWetFactor,
  });

  @override
  Future<void> onPassTime(ItemStack stack, Ts delta) async {
    modify(stack, delta, deltaPerMinute, wetFactor: wetFactor);
  }

  static modify(ItemStack stack, Ts timePassed, double deltaPerMinute, {double wetFactor = 0.0}) {
    var totalDelta = deltaPerMinute * timePassed.minutes;
    final comp = FreshnessComp.of(stack);
    if (comp != null) {
      final freshness = comp.getFreshness(stack);
      final wetness = WetnessComp.tryGetWetness(stack);
      totalDelta *= 1 + wetness * wetFactor;
      comp.setFreshness(stack, freshness + totalDelta);
    }
  }

  factory ContinuousModifyFreshnessComp.fromJson(Map<String, dynamic> json) =>
      _$ContinuousModifyFreshnessCompFromJson(json);

  static Iterable<ContinuousModifyFreshnessComp> of(ItemStack stack) =>
      stack.meta.getCompsOf<ContinuousModifyFreshnessComp>();
  static const type = "ContinuousModifyFreshness";

  @override
  String get typeName => type;
}

extension ContinuousModifyItemPropCompX on Item {
  Item continuousModify(
    Iterable<ItemPropModifier> modifiers,
  ) {
    final comp = ContinuousModifyItemPropComp(modifiers);
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item continuousModifyMass({
    required double deltaPerMinute,
  }) {
    final comp = ContinuousModifyMassComp(
      deltaPerMinute: deltaPerMinute,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item continuousModifyWetness({
    required double deltaPerMinute,
  }) {
    final comp = ContinuousModifyWetnessComp(
      deltaPerMinute: deltaPerMinute,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item continuousModifyFreshness({
    required double deltaPerMinute,
    double wetFactor = FreshnessComp.defaultWetFactor,
  }) {
    final comp = ContinuousModifyFreshnessComp(
      deltaPerMinute: deltaPerMinute,
      wetFactor: wetFactor,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }

  Item continuousModifyDurability({
    required double deltaPerMinute,
    double wetFactor = ContinuousModifyDurabilityComp.defaultWetFactor,
  }) {
    final comp = ContinuousModifyDurabilityComp(
      deltaPerMinute: deltaPerMinute,
      wetFactor: wetFactor,
    );
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}
