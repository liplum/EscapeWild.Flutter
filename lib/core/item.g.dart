// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolItemMeta _$ToolItemMetaFromJson(Map<String, dynamic> json) => ToolItemMeta(
      json['name'] as String,
      toolLevel: $enumDecodeNullable(_$ToolLevelEnumMap, json['toolLevel']) ??
          ToolLevel.normal,
      toolType: ToolType.named(json['toolType'] as String),
      maxDurability: (json['maxDurability'] as num).toDouble(),
    );

const _$ToolLevelEnumMap = {
  ToolLevel.low: 'low',
  ToolLevel.normal: 'normal',
  ToolLevel.high: 'high',
  ToolLevel.max: 'max',
};

ToolItem _$ToolItemFromJson(Map<String, dynamic> json) => ToolItem(
      Contents.getItemMetaByName(json['meta'] as String),
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..durability = (json['durability'] as num).toDouble();

Map<String, dynamic> _$ToolItemToJson(ToolItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['meta'] = _getItemMetaName(instance.meta);
  val['durability'] = instance.durability;
  return val;
}

AttrModifyItemMeta _$AttrModifyItemMetaFromJson(Map<String, dynamic> json) =>
    AttrModifyItemMeta(
      json['name'] as String,
      $enumDecode(_$UseTypeEnumMap, json['useType']),
      (json['modifiers'] as List<dynamic>)
          .map((e) => AttrModifier.fromJson(e as Map<String, dynamic>))
          .toList(),
      afterUsedItem: _namedItemGetter(json['afterUsedItem'] as String),
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
    )..extra = json['extra'] as Map<String, dynamic>?;

Map<String, dynamic> _$CookableItemToJson(CookableItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['meta'] = _getItemMetaName(instance.meta);
  return val;
}

FuelItemMeta _$FuelItemMetaFromJson(Map<String, dynamic> json) => FuelItemMeta(
      json['name'] as String,
      (json['heatValue'] as num).toDouble(),
    );

FuelItem _$FuelItemFromJson(Map<String, dynamic> json) => FuelItem(
      Contents.getItemMetaByName(json['meta'] as String),
    )..extra = json['extra'] as Map<String, dynamic>?;

Map<String, dynamic> _$FuelItemToJson(FuelItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['meta'] = _getItemMetaName(instance.meta);
  return val;
}