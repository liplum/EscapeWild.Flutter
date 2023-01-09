// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttrModifier _$AttrModifierFromJson(Map<String, dynamic> json) => AttrModifier(
      $enumDecode(_$AttrTypeEnumMap, json['attr']),
      (json['delta'] as num).toDouble(),
    );

const _$AttrTypeEnumMap = {
  AttrType.health: 'health',
  AttrType.food: 'food',
  AttrType.water: 'water',
  AttrType.energy: 'energy',
};
