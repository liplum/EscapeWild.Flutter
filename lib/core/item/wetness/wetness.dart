import 'package:escape_wild/core/index.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wetness.g.dart';

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
