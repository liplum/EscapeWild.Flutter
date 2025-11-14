// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wetness.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WetnessComp _$WetnessCompFromJson(Map<String, dynamic> json) => WetnessComp(
  dryTime: json['dryTime'] == null ? WetnessComp.defaultDryTime : Ts.fromJson((json['dryTime'] as num).toInt()),
);

ContinuousModifyWetnessComp _$ContinuousModifyWetnessCompFromJson(Map<String, dynamic> json) =>
    ContinuousModifyWetnessComp(deltaPerMinute: (json['deltaPerMinute'] as num).toDouble());
