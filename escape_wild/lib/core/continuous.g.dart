// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continuous.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContinuousModifyItemPropComp _$ContinuousModifyItemPropCompFromJson(Map<String, dynamic> json) =>
    ContinuousModifyItemPropComp(
      (json['modifiers'] as List<dynamic>).map(ItemPropModifier.fromJson),
    );

ContinuousModifyMassComp _$ContinuousModifyMassCompFromJson(Map<String, dynamic> json) => ContinuousModifyMassComp(
      deltaPerMinute: (json['deltaPerMinute'] as num).toDouble(),
    );
