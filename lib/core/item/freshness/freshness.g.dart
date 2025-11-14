// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freshness.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreshnessComp _$FreshnessCompFromJson(Map<String, dynamic> json) => FreshnessComp(
  expire: Ts.fromJson((json['expire'] as num).toInt()),
  wetFactor: (json['wetFactor'] as num?)?.toDouble() ?? FreshnessComp.defaultWetFactor,
);

ContinuousModifyFreshnessComp _$ContinuousModifyFreshnessCompFromJson(Map<String, dynamic> json) =>
    ContinuousModifyFreshnessComp(
      deltaPerMinute: (json['deltaPerMinute'] as num).toDouble(),
      wetFactor: (json['wetFactor'] as num?)?.toDouble() ?? FreshnessComp.defaultWetFactor,
    );
