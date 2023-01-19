// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_comp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DurabilityComp _$DurabilityCompFromJson(Map<String, dynamic> json) =>
    DurabilityComp(
      (json['max'] as num).toDouble(),
    );

ToolAttr _$ToolAttrFromJson(Map<String, dynamic> json) => ToolAttr(
      efficiency: (json['efficiency'] as num).toDouble(),
    );

ToolComp _$ToolCompFromJson(Map<String, dynamic> json) => ToolComp(
      attr: json['attr'] == null
          ? ToolAttr.normal
          : ToolAttr.fromJson(json['attr'] as Map<String, dynamic>),
      toolType: ToolType.named(json['toolType'] as String),
    );

ModifyAttrComp _$ModifyAttrCompFromJson(Map<String, dynamic> json) =>
    ModifyAttrComp(
      $enumDecode(_$UseTypeEnumMap, json['useType']),
      (json['modifiers'] as List<dynamic>)
          .map((e) => AttrModifier.fromJson(e as Map<String, dynamic>))
          .toList(),
      afterUsedItem: NamedItemGetter.create(json['afterUsedItem'] as String),
    );

const _$UseTypeEnumMap = {
  UseType.use: 'use',
  UseType.drink: 'drink',
  UseType.eat: 'eat',
  UseType.equip: 'equip',
};

FuelComp _$FuelCompFromJson(Map<String, dynamic> json) => FuelComp(
      (json['heatValue'] as num).toDouble(),
    );

WetnessComp _$WetnessCompFromJson(Map<String, dynamic> json) => WetnessComp(
      dryTime: json['dryTime'] == null
          ? WetnessComp.defaultDryTime
          : Ts.fromJson(json['dryTime'] as int),
    );

FreshnessComp _$FreshnessCompFromJson(Map<String, dynamic> json) =>
    FreshnessComp(
      expire: Ts.fromJson(json['expire'] as int),
      wetRotFactor: (json['wetRotFactor'] as num?)?.toDouble() ?? 0.6,
    );

FireStarterComp _$FireStarterCompFromJson(Map<String, dynamic> json) =>
    FireStarterComp(
      chance: (json['chance'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
    );
