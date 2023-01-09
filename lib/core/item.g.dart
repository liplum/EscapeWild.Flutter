// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolItemMeta _$ToolItemMetaFromJson(Map<String, dynamic> json) => ToolItemMeta(
      json['name'] as String,
      $enumDecode(_$ToolLevelEnumMap, json['level']),
      ToolType.named(json['toolType'] as String),
    );

const _$ToolLevelEnumMap = {
  ToolLevel.low: 'low',
  ToolLevel.normal: 'normal',
  ToolLevel.high: 'high',
  ToolLevel.max: 'max',
};

ToolItem _$ToolItemFromJson(Map<String, dynamic> json) => ToolItem(
      Contents.getItemMetaByName(json['meta'] as String),
    )..durability = (json['durability'] as num).toDouble();

Map<String, dynamic> _$ToolItemToJson(ToolItem instance) => <String, dynamic>{
      'meta': _getItemMetaName(instance.meta),
      'durability': instance.durability,
    };

AttrModifyItemMeta _$AttrModifyItemMetaFromJson(Map<String, dynamic> json) =>
    AttrModifyItemMeta(
      json['name'] as String,
      $enumDecode(_$UseTypeEnumMap, json['useType']),
      (json['modifiers'] as List<dynamic>)
          .map((e) => AttrModifier.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

const _$UseTypeEnumMap = {
  UseType.use: 'use',
  UseType.drink: 'drink',
  UseType.eat: 'eat',
};
