import 'dart:ui';
import 'package:escape_wild/core.dart';
import 'package:json_annotation/json_annotation.dart';

import 'wetness.dart';

part 'freshness.g.dart';

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
