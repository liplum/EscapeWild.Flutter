import 'dart:math';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/utils/random.dart';
import 'package:json_annotation/json_annotation.dart';

import 'durability.dart';
import 'wetness.dart';

part 'firestarter.g.dart';

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
