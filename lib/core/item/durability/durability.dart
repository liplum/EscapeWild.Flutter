import 'dart:ui';
import 'package:escape_wild/core/index.dart';
import 'package:json_annotation/json_annotation.dart';

part 'durability.g.dart';

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

  static void modify(ItemStack stack, Ts timePassed, double deltaPerMinute, {double wetFactor = 0.0}) {
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
