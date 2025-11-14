// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_prop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemPropModifier _$ItemPropModifierFromJson(Map<String, dynamic> json) =>
    ItemPropModifier($enumDecode(_$ItemPropEnumMap, json['prop']), (json['deltaPerMinute'] as num).toDouble());

const _$ItemPropEnumMap = {
  ItemProp.mass: 'mass',
  ItemProp.wetness: 'wetness',
  ItemProp.durability: 'durability',
  ItemProp.freshness: 'freshness',
};
