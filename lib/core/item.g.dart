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

CookableItemMeta _$CookableItemMetaFromJson(Map<String, dynamic> json) =>
    CookableItemMeta(
      json['name'] as String,
      (json['flueCost'] as num).toDouble(),
      Contents.getItemMetaByName(json['cookOutput'] as String),
      $enumDecode(_$CookTypeEnumMap, json['cookType']),
    );

const _$CookTypeEnumMap = {
  CookType.cook: 'cook',
  CookType.boil: 'boil',
  CookType.roast: 'roast',
};

CookableItem _$CookableItemFromJson(Map<String, dynamic> json) => CookableItem(
      Contents.getItemMetaByName(json['meta'] as String),
    );

Map<String, dynamic> _$CookableItemToJson(CookableItem instance) =>
    <String, dynamic>{
      'meta': _getItemMetaName(instance.meta),
    };

FuelItemMeta _$FuelItemMetaFromJson(Map<String, dynamic> json) => FuelItemMeta(
      json['name'] as String,
      (json['heatValue'] as num).toDouble(),
    );

FuelItem _$FuelItemFromJson(Map<String, dynamic> json) => FuelItem(
      Contents.getItemMetaByName(json['meta'] as String),
    );

Map<String, dynamic> _$FuelItemToJson(FuelItem instance) => <String, dynamic>{
      'meta': _getItemMetaName(instance.meta),
    };
