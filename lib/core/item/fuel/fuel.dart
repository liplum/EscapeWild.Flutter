import 'package:escape_wild/core/index.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fuel.g.dart';

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
  Item asFuel({required double heatValue}) {
    final comp = FuelComp(heatValue);
    comp.validateItemConfigIfDebug(this);
    addComp(comp);
    return this;
  }
}
