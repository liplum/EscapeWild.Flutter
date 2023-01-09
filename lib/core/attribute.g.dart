// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttrModel _$AttrModelFromJson(Map<String, dynamic> json) => AttrModel(
      health: (json['health'] as num?)?.toDouble() ?? 1.0,
      food: (json['food'] as num?)?.toDouble() ?? 1.0,
      water: (json['water'] as num?)?.toDouble() ?? 1.0,
      energy: (json['energy'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$AttrModelToJson(AttrModel instance) => <String, dynamic>{
      'health': instance.health,
      'food': instance.food,
      'water': instance.water,
      'energy': instance.energy,
    };

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
