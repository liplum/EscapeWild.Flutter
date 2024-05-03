// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'durability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DurabilityComp _$DurabilityCompFromJson(Map<String, dynamic> json) => DurabilityComp(
      max: (json['max'] as num).toDouble(),
      allowExceed: json['allowExceed'] as bool? ?? false,
    );

ContinuousModifyDurabilityComp _$ContinuousModifyDurabilityCompFromJson(Map<String, dynamic> json) =>
    ContinuousModifyDurabilityComp(
      deltaPerMinute: (json['deltaPerMinute'] as num).toDouble(),
      wetFactor: (json['wetFactor'] as num?)?.toDouble() ?? ContinuousModifyDurabilityComp.defaultWetFactor,
    );
