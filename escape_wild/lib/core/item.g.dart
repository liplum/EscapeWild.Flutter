// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemEntry _$ItemEntryFromJson(Map<String, dynamic> json) => ItemEntry(
      Contents.getItemMetaByName(json['meta'] as String),
      mass: json['mass'] as int?,
    )..extra = json['extra'] as Map<String, dynamic>?;

Map<String, dynamic> _$ItemEntryToJson(ItemEntry instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['meta'] = _getItemMetaName(instance.meta);
  writeNotNull('mass', instance.mass);
  return val;
}

ToolComp _$ToolCompFromJson(Map<String, dynamic> json) => ToolComp(
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

ModifyAttrComp _$ModifyAttrCompFromJson(Map<String, dynamic> json) =>
    ModifyAttrComp(
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

CookableComp _$CookableCompFromJson(Map<String, dynamic> json) => CookableComp(
      $enumDecode(_$CookTypeEnumMap, json['cookType']),
      (json['fuelCost'] as num).toDouble(),
      _namedItemGetter(json['cookedOutput'] as String),
    );

const _$CookTypeEnumMap = {
  CookType.cook: 'cook',
  CookType.boil: 'boil',
  CookType.roast: 'roast',
};

FuelComp _$FuelCompFromJson(Map<String, dynamic> json) => FuelComp(
      (json['heatValue'] as num).toDouble(),
    );
