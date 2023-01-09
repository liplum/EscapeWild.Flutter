// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttrModifier _$AttrModifierFromJson(Map<String, dynamic> json) => AttrModifier(
      $enumDecode(_$AttrEnumMap, json['attr']),
      (json['delta'] as num).toDouble(),
    );

const _$AttrEnumMap = {
  Attr.health: 'health',
  Attr.food: 'food',
  Attr.water: 'water',
  Attr.energy: 'energy',
};
