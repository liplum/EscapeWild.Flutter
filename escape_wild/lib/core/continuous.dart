import 'package:escape_wild/core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'continuous.g.dart';

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
